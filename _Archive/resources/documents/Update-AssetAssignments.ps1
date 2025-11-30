Param(
    [string] $StorageAccountName = "hekspowerbiazsync",
    [string] $ContainerName      = "manualdb",
    [string] $DepartmentsPath    = "Departments",
    [string] $AssetsPath         = "AssetsCatalog",
    [bool] $TestMode             = $true
)

## --------------------- Environment ---------------------
$ErrorActionPreference = 'Stop'

# Disable coloured output for the whole runbook - this makes for more readable runbook outputs
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText

## --------------------- Functions ---------------------

function Set-StorageContext {
    param (
        $StorageAccountName,
        $ContainerName
    )
    
    # Authentication for Az Storage Access
    Disable-AzContextAutosave -Scope Process
    $azureContext = (Connect-AzAccount -Identity).Context
    Set-AzContext -SubscriptionName $azureContext.Subscription -DefaultProfile $azureContext

    # set context for az Storage Access 
    $storageContext = (New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount)

    return $storageContext
}

function Get-LatestBlobData {  # TODO - implement this function on all other Runbooks
    param (
        $StorageContext,
        $ContainerName,
        $BasePath,
        $TempPath
    )
    
    # Get all blobs/files
    try{
        $allBlobs = Get-AzStorageBlob -Container $ContainerName -Context $StorageContext -Prefix $BasePath

    } catch {
        throw "Error, couldn't get Data Blobs. Eror Message: $_"
    }

    if (-not $allBlobs) {
        throw "No blobs found under prefix '$BasePath'"
    }

    # Filter out the parent folder blob
    $fileBlobs = $allBlobs | Where-Object { $_.Length -ne 0 }

    $latest = $fileBlobs |
    # get latest fileileBlobs |
        Sort-Object { $_.BlobProperties.LastModified } -Descending |
        Select-Object -First 1

    Write-Verbose "Using blob: $($latest.Name) (LastModified: $($latest.BlobProperties.LastModified))"

    # Download JSON File into temp Folder 
    try {
        Get-AzStorageBlobContent -Container $ContainerName -Blob $latest.Name -Destination $TempPath -Context $storageContext -Force
    }
    catch {
        throw "Error, couldn't download Data from Blob. Eror Message: $_"
    }
    
    # Import downloaded JSON File
    $data = Get-Content -Raw -Path $TempPath | ConvertFrom-Json

    return $data
}


function New-AssignmentRule {
    param (
        $Codes
    )

    $quotedCodes = @()

    foreach ($code in $Codes) { 
        $quotedCodes += "'$code'" 
    }

    $rule = "(user.extensionAttribute1 -in [" + ($quotedCodes -join ',') + "])"

    if ($rule.Length -gt 3072) {
        throw "Rule exceeds 3 072-character limit. Rule: $rule"
    }
    
    return $rule
}

## --------------------- Definitions ---------------------

Connect-AzAccount -Identity
Connect-MgGraph  -Identity -Scopes "Group.ReadWrite.All"

# Define a local temp path 
$tempPathDepartments = Join-Path $env:TEMP 'DepartmentsData.json'
$tempPathAssets = Join-Path $env:TEMP 'AssetsData.json'

# Get storage Context
$StorageContext = Set-StorageContext -StorageAccountName $StorageAccountName -ContainerName $ContainerName

## --------------------- Download Data ---------------------

$DepartmentList = Get-LatestBlobData -StorageContext $StorageContext -ContainerName $ContainerName -BasePath $DepartmentsPath -TempPath $tempPathDepartments

$AssetList = Get-LatestBlobData -StorageContext $StorageContext -ContainerName $ContainerName -BasePath $AssetsPath -TempPath $tempPathAssets

## --------------------- Execution ---------------------

# Build List of Assets and departments they need to be assigned to

$codesByGroup = @{}

foreach ($department in $DepartmentList) {

    if ($department.Approved -ne "YES") { # Skip unapproved Departments
        continue
    }

    # collect codes this department contributes
    $departmentCodes = @($department.DepartmentCode)

    if ($department.SpecialCodes) {

        foreach ($code in ($department.SpecialCodes -split ',')) {
            $trimmed = $code.Trim()

            if ($trimmed) { # excludes empty strings
                $departmentCodes += $trimmed 
            }
        }
    }

    # map those codes to every group listed for the department
    foreach ($groupName in ($department.AssignedAssetsSecurityGroups -split ',')) {

        $cleanName = $groupName.Trim()
        if (-not $cleanName) { continue } # excludes empty strings

        if (-not $codesByGroup.ContainsKey($cleanName)) { 
            $codesByGroup[$cleanName] = @() 
        }

        $codesByGroup[$cleanName] += $departmentCodes
    }
}


# Update Rules for Asset Groups

foreach ($asset in $AssetList) {

    $securityGroupName = $asset.SecurityGroup.Trim()

    $requiredCodes     = if ($codesByGroup.ContainsKey($securityGroupName)) { 
                            $codesByGroup[$securityGroupName] 
                         } else { 
                            @('EMPTY') # if no department was assigned yet
                         }

    # Find the dynamic group by its display-name
    $filter = "displayName eq '$securityGroupName' and " + "groupTypes/any(c:c eq 'DynamicMembership')"

    $group  = Get-MgGroup -Filter $filter `
              -Property membershipRule,membershipRuleProcessingState `
              -ConsistencyLevel eventual -ErrorAction SilentlyContinue

    if (-not $group) {
        Write-Output "WARNING: group '$securityGroupName' not found"
        continue
    }
    if ($group.Count -gt 1) {
        Write-Output "WARNING: duplicate groups named '$securityGroupName'"
        continue
    }

    #  Compose the  rule
    try {
        $newRule = New-AssignmentRule -Codes $requiredCodes
    }
    catch {
        throw $_
    }

    # Push the change only if needed
    if ($group.membershipRule -ne $newRule -or
        $group.membershipRuleProcessingState -ne 'On') {

        Write-Output "Updating rule for '$securityGroupName'"

        if ( $TestMode ) {
            Update-MgGroup -GroupId $group.Id `
                        -MembershipRule $newRule `
                        -MembershipRuleProcessingState "On" `
                        -WhatIf
        } else {
            Update-MgGroup -GroupId $group.Id `
                        -MembershipRule $newRule `
                        -MembershipRuleProcessingState "On"
        }
    }
    else {
        Write-Output "'$securityGroupName' already up to date"
    }
}


## Notes: 

# Assigned az role: Groups administrator

#Code to create new Asset Group

<# 
New-MgGroup `
  -DisplayName                    "DG_Asset_<name>" `
  -Description                    "Asset group – dynamic membership" `
  -SecurityEnabled                `
  -MailEnabled:$false             `
  -GroupTypes                     @("DynamicMembership") `
  -MembershipRule                 "(user.extensionAttribute1 -in ['EMPTY'])" `
  -MembershipRuleProcessingState  "On"
 #>

<# New-MgGroup `
  -DisplayName                    "EID_D_Asset_IntuneTest" `
  -Description                    "Test Asset group dynamic membership" `
  -MailNickname                   "eid_d_asset_intunetest" `
  -SecurityEnabled                `
  -MailEnabled:$false             `
  -GroupTypes                     @("DynamicMembership") `
  -MembershipRule                 "(user.extensionAttribute1 -in ['SRVICTSYS','SRVICTSUP'])" `
  -MembershipRuleProcessingState  "On" #>