param(
    [Parameter(Mandatory = $false)]
[string] $StorageAccountName = "hekspowerbiazsync",

[Parameter(Mandatory = $false)]
[string] $ContainerName = "powerbi",

[Parameter(Mandatory = $true)] # TEMP
[string] $JsonFilePath,

[Parameter(Mandatory = $false)]
[string] $LogRetentionDays = 60,

[Parameter(Mandatory = $false)]
[bool] $TestMode = $false
)

# --------- Dependencies ---------
# Because this runbook is excuted localy on a hybrid worker, modules must be imported on the server locally

# List of modules your runbook depends on
$requiredModules = @(
'ActiveDirectory',
'Az.Accounts',
'Az.Storage'
)

foreach ($module in $requiredModules) {
# If the module isn't installed system-wide, install it
if (-not (Get-Module -ListAvailable -Name $module)) {
    Write-Output "Installing PowerShell module: $module"
    Install-Module -Name $module -Scope AllUsers -Force -ErrorAction Stop
}

# Import the module so its cmdlets are available
Import-Module -Name $module -ErrorAction Stop
}

# --------- Functions ---------
function Write-Log {
param([string]$Message, [string]$Level = 'INFO')
$line = "{0} [{1}] {2}" -f (Get-Date -Format "s"), $Level, $Message
$line | Out-File -FilePath $logPath -Append -Encoding UTF8
}

function Write-UserBackup {
param(
    [Parameter(Mandatory)]
    $ADUser
)

try{
    $ADUser | Export-Csv -Path $backupPath -NoTypeInformation -Append -Encoding UTF8 -Force
} catch {
    Write-Log "Error, could not backup this user. User info: `n $ADUser" 'ERROR'
}

}

function Remove-OldLogFiles {
param(
    [Parameter(Mandatory)]
    [string] $FolderPath,

    [int] $RetentionDays
)

# Calculate cutoff date
$cutoffDate = (Get-Date).AddDays(-$RetentionDays)

# Find and remove files older than cutoffDate
Get-ChildItem -Path $FolderPath -File |
    Where-Object { $_.LastWriteTime -lt $cutoffDate } |
    Remove-Item -Force -ErrorAction Stop
}

# --------- Definitions ---------

# Retrieve the credential asset for local AD # TODO - chjange to passwordless
$localADCreds = Get-AutomationPSCredential -Name 'Service Account for Local AD'
if (-not $localADCreds) {
throw 'Credential asset "Service Account for Local AD" not found'
}


# set logpaths
$timestamp      = Get-Date -Format "yyyy-MM-dd_HHmmss"
$logFolderPath  = "C:\SwSalAzureADSync\Logfiles\"
$transcriptPath = "$logFolderPath" + "Transcript_$timestamp.txt"
$logPath        = "$logFolderPath" + "ADSyncLog_$timestamp.txt"
$backupPath     = "C:\SwSalAzureADSync\Backup\" + "ADUsersBackup_$timestamp.csv"

# Define local download path for Json Data download
$tempJsonFile = Join-Path $env:TEMP (Split-Path $JsonFilePath -Leaf)

# Authentication for Az Storage Access
Disable-AzContextAutosave -Scope Process
$azureContext = (Connect-AzAccount -Identity).Context
Set-AzContext -SubscriptionName $azureContext.Subscription -DefaultProfile $azureContext

# set context for az Storage Access 
$storageContext = (New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount)

# attribute des AD users - attribute deren namen vom PowerBi Namen abweichen sind kommentiert
$UserPropertiesToCompare = @(
'employeeID',                               # TODO - wenn alle user in AD korrekt gesynced wird, diesen zum filtern nutzen
'userPrincipalName',                        # Excluded from Sync
'givenName',            # First name
'sn',                   # surname
'initials',
'company',
'title',                # Job Title
'department',           # Department Description
'division',             # Kostenstelle
'extensionAttribute1',  # Departmentcode
'extensionAttribute2',  # languageCode
'streetAddress',
'l',                    # City name
'st',                   # state/kanton name
'postalCode',
'c',                    # 2 Digit country code (e.g "CH")
'co',                   # Country Name in English
'countryCode'           # Numeric country code - windows specific country number
)

# Map incoming JSON(SwissSalary) fields to AD attribute names
$AttributeMap = @{
'EmployeeID'            = 'employeeID'           
'UserPrincipalName'     = 'userPrincipalName'    
'Firstname'             = 'givenName'           
'Surname'               = 'sn'                   
'Initials'              = 'initials'             
'Company'               = 'company'              
'JobTitel'              = 'title'                
'DepartmentDescription' = 'department'           
'DepartmentCode'        = 'extensionAttribute1'  
'Division'              = 'division'             
'LanguageCode'          = 'extensionAttribute2'  
'StreetAdress'          = 'streetAddress'        
'City'                  = 'l'                    
'State'                 = 'st'                   
'PostalCode'            = 'postalCode'           
'CountryCode'           = 'c'
'CountryFullname'       = 'co'
'CountryNumeric'        = 'countryCode'  
}

# Attributes excluded from Update Loop (Intentionally Hardcoded, DO NOT TOUCH!)
$ExcludeAttributes = @('userPrincipalName', 'givenName', 'sn')  # TODO - umbenenung , was passiert?


# --------- Execution ---------

# Start new Log-Transcript
Start-Transcript -Path $transcriptPath -Append

if($TestMode){
Write-Log "TESTMODE STARTED - User Attributes will not actually be changed"
}

# Clean Log Files from Hybrid Worker Server
Remove-OldLogFiles -FolderPath $logFolderPath -RetentionDays $LogRetentionDays

# Download Json File 
Get-AzStorageBlobContent `
-Container   $ContainerName `
-Blob        $JsonFilePath `
-Destination $tempJsonFile `
-Context     $storageContext `
-Force

# Convert to PS Object for easier handling
$jsonString = Get-Content -Path $tempJsonFile -Raw
$employeeList = $jsonString | ConvertFrom-Json


foreach ($user in $employeeList) {

# Validate UPN format
if ($user.UserPrincipalName -notmatch '^[^@]+@(?:heks\.ch|eper\.ch|heks-eper\.org)$') {
    Write-Log "Skipping user with unexpected UPN format: $($user.UserPrincipalName)" 'WARN'
    continue
}

# Retrieve current AD user with necesary properties + SamAccountname
try {
    # Add SamAccount name to Array of properties we want to retrieve from user
    $userProperties = $UserPropertiesToCompare + 'SamAccountName'
    $ldapFilter = "(userPrincipalName=$($user.UserPrincipalName))"

    $currentADUser = Get-ADUser -LDAPFilter $ldapFilter -Properties $userProperties -ErrorAction Stop
    Write-UserBackup $currentADUser

    if (-not $currentADUser) {
        Write-Log "No AD user found for $($user.UserPrincipalName)" 'WARN'
        continue
    }
}
catch {
    Write-Log "Error retrieving AD user $($user.UserPrincipalName): $_" 'ERROR'
    continue
}


# Prepare update hashtable and change log
$updates    = @{}
$changed    = @()

foreach ($jsonField in $AttributeMap.Keys) {
    $adAttrName = $AttributeMap[$jsonField]

    # Some JSON fields may map to multiple AD attributes (if needed adjust to array)
    $newValue = $user.$jsonField
    $oldValue = $currentADUser.$adAttrName

    # Normalize nulls/empty
    if ($null -eq $newValue) { $newValue = '' }
    if ($null -eq $oldValue) { $oldValue = '' }

    # Trim strings for comparison
    if ($newValue -is [string]) { $newValue = $newValue.Trim() }
    if ($oldValue -is [string]) { $oldValue = $oldValue.Trim() }

    # (DO NOT TOUCH!) Attributes Excluded from AD Update-Loop - Review & Alert only 
    if ($ExcludeAttributes -contains $adAttrName) {
        Write-Log "Skipping update of excluded attribute: $adAttrName" 'DEBUG'

        if($newValue -ne $oldValue){
            Write-Log "Excluded Attribute ($adAttrName) value differs from BC. Current Value: $oldValue -> New Value: $newValue" 'WARN'
        }
        # skipping update loop
        continue
    }

    # Compare
    if ($newValue -ne $oldValue) {
        if ($newValue -eq '') {
            # Clear the attribute
            $updates[$adAttrName] = $null
            $changed += "$adAttrNamen = '$oldValue' -> <cleared>"
        }
        else {
            $updates[$adAttrName] = $newValue
            $changed += "$adAttrName = '$oldValue' -> '${$newValue}'"
        }
    }
}

# Apply updates if there are changes
if ($updates.Count -gt 0) {
    try {
        $updatesText = $updates | Format-List | Out-String

        if($TestMode){
            # Log Updates it would do
            Write-Log "TESTMODE 01 - user ( $($user.UserPrincipalName) ) updates it would do: `n$updatesText `n" 'DEBUG'
            
            # TODO 
            # What to do with name updates? e.g. Petra Graf
            # what to do with email? should be input too

            Set-ADUser -Identity $currentADUser.SamAccountName -Replace $updates -Credential $localADCreds -WhatIf

            # Info About "-Whatif": https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.5
            
        }
        else{
            Write-Log "User will be updated. UPN: $($user.UserPrincipalName)" 'INFO'

            # Use -Replace for setting or clearing attributes
            Set-ADUser -Identity $currentADUser.SamAccountName -Replace $updates -Credential $localADCreds
            Write-Log "Updated $($user.UserPrincipalName) attributes: `n$updatesText"
        }
    }
    catch {
        Write-Log "Failed to update $($user.UserPrincipalName): $_ `n Updates it should have done: `n$updatesText" 'ERROR'
    }
}
else {
    Write-Log "No changes for $($user.UserPrincipalName)"
}
}

# --------- Output ---------

Stop-Transcript
