param(
    [Parameter(Mandatory)]
    [string] $CsvFilename,

    [Parameter(Mandatory = $false)]
    [string] $BackupPath = "C:\SwSalAzureADSync\Backup\",

    [Parameter(Mandatory = $false)]
    [bool] $TestMode = $false
)

# --------- Dependencies ---------
# Because this runbook is excuted localy on a hybrid worker, modules must be imported on the server locally

# List of modules your runbook depends on
<# $requiredModules = @(
    'ActiveDirectory'
)

foreach ($module in $requiredModules) {
    # If the module isn't installed system-wide, install it
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Output "Installing PowerShell module: $module"
        Install-Module -Name $module -Scope AllUsers -Force -ErrorAction Stop
    }

    # Import the module so its cmdlets are available
    Import-Module -Name $module -ErrorAction Stop
} #>

# --------- Functions ---------
function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "{0} [{1}] {2}" -f (Get-Date -Format "s"), $Level, $Message
    $line | Out-File -FilePath $logPath -Append -Encoding UTF8
}

# --------- Definitions ---------


# Retrieve the credential asset for local AD
$localADCreds = Get-AutomationPSCredential -Name 'Service Account for Local AD'
if (-not $localADCreds) {
    throw 'Credential asset "Service Account for Local AD" not found'
}

# set logpaths
$timestamp      = Get-Date -Format "yyyy-MM-dd_HHmmss"
$logFolderPath  = "C:\SwSalAzureADSync\Logfiles\"
$transcriptPath = "$logFolderPath" + "Rollback_Transcript_$timestamp.txt"
$logPath        = "$logFolderPath" + "Rollback_ADSyncLog_$timestamp.txt"

# Build the full CSV path
$csvPath = Join-Path $BackupPath $CsvFilename

# Ensure the file exists
if (-not (Test-Path $csvPath)) {
    Write-Log "Backup CSV not found at: $csvPath" 'ERROR'
    throw "File not found: $csvPath"
}

$propertiesToFetch = $csvHeader | Where-Object { $_ -notin $immutable }

# --------- Execution ---------

# Start new Log-Transcript
Start-Transcript -Path $transcriptPath -Append

if($TestMode){
    Write-Log "TESTMODE STARTED - User Attributes will not actually be changed"
}

# TODO - GET Users from backup csv
$backupEntries = Import-Csv -Path $csvPath

foreach ($user in $backupEntries) {

    # Retrieve current AD user with necesary properties
    try {
        $currentADUser = Get-ADUser -Identity $($user.SamAccountName) -Properties $propertiesToFetch -ErrorAction Stop
        Write-Log "ad user:$currentADUser" 'DEBUG' #TODO - edit 
    }
    catch {
        Write-Log "Error retrieving AD user $($user.SamAccountName): $_" 'ERROR'
        continue
    }
    if (-not $currentADUser) {
        Write-Log "No AD user found for $($user.SamAccountName)" 'WARN'
        continue
    }


    # Prepare update hashtable and change log
    $toRestore  = @{}
    $changeLog  = @()

    foreach ($prop in $propertiesToFetch) {

        $csvValue     = $user.$prop
        $adValue      = $currentADUser.$prop

        # Normalize nulls/empty
        if ($null -eq $csvValue) { $csvValue = '' }
        if ($null -eq $adValue) { $adValue = '' }

        # Trim strings for comparison
        if ($csvValue -is [string]) { $csvValue = $csvValue.Trim() }
        if ($adValue -is [string]) { $adValue = $adValue.Trim() }

        # Compare
        if ($csvValue -ne $adValue) {
            if ($csvValue -eq '') {
                # Clear the attribute
                $toRestore[$adAttrName] = $null
                $changeLog += "$adAttrNamen = '$adValue' -> <cleared>"
            }
            else {
                $toRestore[$adAttrName] = $csvValue
                $changeLog += "$adAttrName = '$adValue' -> '${$csvValue}'"
            }
        }
    }

    # Apply changes if there are changes
    if ($toRestore.Count -gt 0) {
        try {
            if($TestMode){
                # Log Updates it would do
                $updatesText = $toRestore | Format-List | Out-String
                Write-Log "TESTMODE 01 - user ( $($user.UserPrincipalName) ) updates it would do: `n$updatesText `n" 'DEBUG'
                
                # TODO 
                # What to do with name updates? e.g. Petra Graf
                # what to do with email? should be input too

                Set-ADUser -Identity $currentADUser.SamAccountName -Replace $toRestore -Credential $localADCreds -WhatIf

                # Info About "-Whatif": https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.5
                
            }
            else{
                # Use -Replace for setting or clearing attributes
                Set-ADUser -Identity $currentADUser.SamAccountName -Replace $toRestore -Credential $localADCreds -WhatIf #-ErrorAction Stop 
                Write-Log "Rolled Back user $($user.UserPrincipalName): $(($changeLog -join '; '))"
            }
        }
        catch {
            Write-Log "Failed to edit $($user.UserPrincipalName): $_" 'ERROR'
        }
    }
    else {
        Write-Log "No changes for $($user.UserPrincipalName)"
    }
}

# --------- Output ---------

Stop-Transcript
