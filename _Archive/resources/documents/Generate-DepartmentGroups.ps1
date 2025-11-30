Param(
    [string] $StorageAccountName = "hekspowerbiazsync",
    [string] $ContainerName      = "manualdb",
    [string] $BasePath           = "Departments",
    [bool] $TestMode             = $false, # set default to false after testing - TODO
    [bool] $TestModeAdvanced     = $true, # script executed normaly but with test input file
    [bool] $Force                = $false # Forces the script to rename current DDLs to ".._old"
)

<#  IMPORTANT NOTE:
    This Runbook must be executed on a Hybrid Runbook Worker
    because of compatibility issues with the ExchangeOnline Module
    with AzAutomation ran in the cloud.
    It will not be able to connect to exchange online if you
    run it in the cloud.
 #>

## ------- functions -------

# Create full hierarchy Table of Departments & Parent & Children
function Build-DeptTable {
    param($rows)
    $DeptTable = @{}
    foreach ($row in $rows) {
        $code = $row.Code.Trim()
        $DeptTable[$code] = [ordered]@{
            Code         = $code
            Description  = $row.Description.Trim()
            Parent       = $row.ParentCode.Trim()
            Children     = @()
            SpecialCodes      = if ($row.SpecialCodes) { ($row.SpecialCodes -split ',') | %{ $_.Trim() } } else { @() } # TODO - make sure its null if there are no special codes
        }
    }
    foreach ($department in $DeptTable.Values) {
        $parent = $department.Parent
        if ($parent -and $DeptTable.ContainsKey($parent)) {
            $DeptTable[$parent].Children += $department.Code
        }
    }
    return $DeptTable
}

# Helper Function to generate Query for DL's
function Get-Filter {
    param($deptCode)

    $department = $DeptTable[$deptCode]

    $codes = @() # array of strings

    if ($department.SpecialCodes.Count -ne 0) {
        $codes += $department.SpecialCodes
    }
    $codes += $department.Code

    $queue = New-Object System.Collections.Queue
    $department.Children | % { $queue.Enqueue($_) }

    while ($queue.Count -gt 0) {
        $childCode = $queue.Dequeue()
        $childDept = $DeptTable[$childCode]

        $codes += $childDept.Code
        $codes += $childDept.SpecialCodes
        $childDept.Children | % { $queue.Enqueue($_) }
    }

    $codes = $codes | Sort-Object -Unique
    $codesString = $codes -join ','
    return $codesString
}

# Create or Update Dynamic distribution Group
function Set-DynamicDistributionList {
    param($alias, $name, $filter, $smtpAddress)

    $existingAlias = Get-DynamicDistributionGroup -Identity $smtpAddress -ErrorAction SilentlyContinue
    $existingName = Get-DynamicDistributionGroup -Identity $smtpAddress -ErrorAction SilentlyContinue

    #IF same name, different alias
    if ($existingName -and ($existingAlias.PrimarySmtpAddress -ne $smtpAddress)) {
        
        Write-Debug "DDL with name $name already exists, but has different alias (probably old version DDL). Use the parameter 'Force' to rename the existing DDL to'..._old'."
        
        if ($Force) {
            # Rename old DDL and create new one (will take 24 hours to update names in the adressbook)
            $newName = "$($existingName.DisplayName) - old"
            
            if ($TestMode) { 
                # Doesnt actually change anything
                Set-DynamicDistributionGroup -Identity $existingName.PrimarySmtpAddress -Name $newName -DisplayName $newName -WhatIf
                New-DynamicDistributionList -alias $alias -name $name -filter $filter -smtpAddress $smtpAddress #doesnt need whatif cause it tests for $Testmode too
            } else {
                try {
                    Set-DynamicDistributionGroup -Identity $existingName.PrimarySmtpAddress -Name $newName -DisplayName $newName -ForceMembershipRefresh -ErrorAction Stop
                    New-DynamicDistributionList -alias $alias -name $name -filter $filter -smtpAddress $smtpAddress
                }
                catch {
                    $errorText = Format-Error $_
                    Write-Error $errorText
                    throw "An Error occured. Could not update DDL $($smtpAddress)."
                }
            }
            
        }
        else {
            Write-Warning "The $name DDL with alias $alias was not created, because the param -Force was not used."
        }
    }

    #IF same alias, different name (name update)
    if ($existingAlias -and ($existingAlias.DisplayName -ne $name)) {
        Write-Output "DDL $smtpAddress already exists but name changed. Name is being updated"

        if ($TestMode) { 
            # Doesnt actually change anything
            Set-DynamicDistributionGroup -Identity $smtpAddress -Name $name -DisplayName $name -WhatIf
        } else {
            try {
                Set-DynamicDistributionGroup -Identity $smtpAddress -Name $name -DisplayName $name -ForceMembershipRefresh -ErrorAction Stop
            }
            catch {
                $errorText = Format-Error $_
                Write-Error $errorText
                throw "An Error occured. Could not update DDL $($smtpAddress)."
            }
            
        }
    }

    # if same name and alias - update filter
    if ($existingAlias -and $existingName) {

        Write-Output "DDL $smtpAddress already exists (same name and alias). DDL filter is being updated"

        # Compare current values before updating
        $currentFilter = $existingAlias.ConditionalCustomAttribute1.Trim()

        if (($currentFilter -ne "{$($filter)}")) {
            Write-Output "Updating DDL $smtpAddress because Filter changed."

            if ($TestMode) { 
                # Doesnt actually change anything
                Set-DynamicDistributionGroup -Identity $smtpAddress -ConditionalCustomAttribute1 $filter -WhatIf
            } else {
                try {
                    Set-DynamicDistributionGroup -Identity $smtpAddress -ConditionalCustomAttribute1 $filter -ForceMembershipRefresh -ErrorAction Stop
                }
                catch {
                    $errorText = Format-Error $_
                    Write-Error $errorText
                    throw "An Error occured. Could not update DDL $($smtpAddress)."
                }
                
            }
        } else {
            Write-Output "No changes for $smtpAddress; skipping update."
        }
    }
    
    # IF doesnt exist yet
    else {
        New-DynamicDistributionList -alias $alias -name $name -filter $filter -smtpAddress $smtpAddress
    }
}


function New-DynamicDistributionList {
    param($alias, $name, $filter, $smtpAddress)

    Write-Output "Creating new DDL $smtpAddress"

    if ($TestMode) {
        # Doesnt actually change anything
        New-DynamicDistributionGroup -Name $name -Alias $alias -PrimarySmtpAddress $smtpAddress -IncludedRecipients MailboxUsers -ConditionalCustomAttribute1 $filter -WhatIf
        Write-Output $testresult
    } else {
        try {
            New-DynamicDistributionGroup -Name $name -Alias $alias -PrimarySmtpAddress $smtpAddress -IncludedRecipients MailboxUsers -ConditionalCustomAttribute1 $filter -ErrorAction Stop
            Set-DynamicDistributionGroup -Identity $smtpAddress -HiddenFromAddressListsEnabled $true -ForceMembershipRefresh -ErrorAction Stop #TODO - remove hidden?
        }
        catch {
            $errorText = Format-Error $_
            Write-Error $errorText
            throw "An Error occured. Could not create DDL $($smtpAddress)."
        }
    }
}

# Compute hierarchical alias e.g. dl_srv_ict_sys
function Get-HierarchicalAlias {
    param($deptCode)

    $parts = @()
    $cursor = $deptCode   # cursor: Current Department Code

    while ($cursor) {
        $code = $cursor
        $parent = $DeptTable[$cursor].Parent

        if ($parent) {
            # Remove Parent from current prefix
            if ($code.StartsWith($parent)) {
                $code = $code.Substring($parent.Length)
            }
        }

        # prepend current code to parts of alias
        $parts = @($code) + $parts
        $cursor = $parent
    }

    return "dl_" + ($parts -join '_').ToLower()  # TODO - add mail domain
}

function Remove-AnsiFormatting {
    param([string]$String)
    # Regex removes ESC[ … command sequences
    return [regex]::Replace($String, "`e\[[\d;]*[a-zA-Z]|\r?\n", '')
}

function Format-Error {
    param ($object)

    # Grab the Exception object
    $ex = $object.Exception

    # extract relevant data
    $type    = $ex.GetType().Name        # e.g. "ManagementObjectNotFoundException"
    $message = $ex.Message               # the human-readable message
    $stack   = $ex.StackTrace            # optional: for deeper debugging

    # Build one single line (or multi-line) string
    $cleanError = "$type : $message`nStack:`n$stack"
  

    $cleanError = Remove-AnsiFormatting $cleanError

    return $cleanError
}

## ------- Definitions -------

# Important to make errors mark the runbook job as failed in az automation
$ErrorActionPreference = "Stop"

# Disable coloured output for the whole runbook - this makes for more readable runbook outputs
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText


# Ensure ExchangeOnlineManagement is available
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Output "ExchangeOnlineManagement module not found; installing..."
    Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
} else {
    Write-Output "ExchangeOnlineManagement module already installed."
}

# Import it if not already imported
if (-not (Get-Module -Name ExchangeOnlineManagement)) {
    Write-Output "Importing ExchangeOnlineManagement module..."
    Import-Module ExchangeOnlineManagement -ErrorAction Stop
} else {
    Write-Output "ExchangeOnlineManagement module already loaded."
}

# Define a local temp path 
$tempCsvFile = Join-Path $env:TEMP 'Departments.csv'

# Authentication for Az Storage Access
Disable-AzContextAutosave -Scope Process
$azureContext = (Connect-AzAccount -Identity).Context
Set-AzContext -SubscriptionName $azureContext.Subscription -DefaultProfile $azureContext

# set context for az Storage Access 
$storageContext = (New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount)

## ------- Retrieve Data from StorageAccount -------  # TODO - make this a function, retreive latest blob from Az account

# Get all blobs/files
try{
    if ($TestModeAdvanced) {
        $allBlobs = Get-AzStorageBlob -Container $ContainerName -Context $storageContext -Prefix "TestData"
    }
    else {
        $allBlobs = Get-AzStorageBlob -Container $ContainerName -Context $storageContext -Prefix $BasePath
    }
    
} catch {
    $errorText = Format-Error $_
    throw "Error, couldn't get Data Blobs. Eror Message: $($errorText)"
}

if (-not $allBlobs) {
    throw "No blobs found under prefix '$($BasePath)'"
}

# Filter out the parent folder blob
$fileBlobs = $allBlobs | Where-Object { $_.Length -ne 0 }

# get latest file
$latest = $fileBlobs |
    Sort-Object { $_.BlobProperties.LastModified } -Descending |
    Select-Object -First 1

Write-Output "Using blob: $($latest.Name) (LastModified: $($latest.BlobProperties.LastModified))"

# Download CSV File into temp Folder
try {
    Get-AzStorageBlobContent -Container $ContainerName -Blob $latest.Name -Destination $tempCsvFile -Context $storageContext -Force
}
catch {
    $errorText = Format-Error $_
    throw "Error, couldn't get Storage Blob Content. Eror Message: $($errorText)"
}


# Import downloaded CSV File & Convert to JSON
$raw = Import-Csv -Path $tempCsvFile -Delimiter ';'

## ------- Main Execution -------

# Create Hierarchical Department Table
$DeptTable = Build-DeptTable -rows $raw
#Write-Output ($DeptTable | ConvertTo-Json -Depth 10)   # TODO - output it or not?

try {
    Connect-ExchangeOnline -ManagedIdentity -Organization "heks.onmicrosoft.com"
}
catch {
    $errorText = Format-Error $_
    throw "Error, couldn't connect to Exchange Online. Eror Message: $($errorText)"
}


# Create or Update Dynamic distribution List for each department
foreach ($code in $DeptTable.Keys) {
    $department = $DeptTable[$code]
    $alias = Get-HierarchicalAlias -deptCode $code
    $smtpAddress = "$alias@heks.ch"
    $name  = "$($department.Description)"
    $filter = Get-Filter -deptCode $code

    # TODO - add description (.Notes) for DL -> CODE - Description needed!

    Write-Output "INFO | Current Group: $code -> $alias -> $smtpAddress -> $filter"

    Set-DynamicDistributionList -alias $alias -name $name -filter $filter -smtpAddress $smtpAddress
   
}


Write-Output "All dynamic distribution groups have been created/updated."
# TODO - RENAME cause it only generates DDL's 