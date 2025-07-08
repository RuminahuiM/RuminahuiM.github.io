---
layout: default
title: Produkte / Artefakte
parent: 3. Projektdurchführung
nav_order: 2
---

{: .no_toc }

# Produkte / Artefakte / Komponenten (TODO - find the best title)

Dieses Projekt besteht aus verschiedenen Komponenten/Features. Deshalb teile ich im folgenden, dass Porjekt in verschiedene Artefakte ein, die aus dem Projekt entstanden sind und die wiederum diverse komponenten benötigen aber jeweils nur 1 feature darstellen.

## Swiss Salary zu AD Synchronisation

TODO - passt der name artefakte? ansonsten ersetzen

Dieses Artefakt war usprünglich nicht als teil dieses Projekts angedacht. Allerdings ist es nötig, damit dieses Projekt funktioniert. Zuerst wollte ich es im vorhinein vorbereiten aber das wurde selbst zu komplex und ausserdem ist es eigentlich schon teil des projekts, da es eine dependencie darstellt.

Dabei geht es darum, das wir ja aktuell die Mitarbeiter Daten wie z.b. Abteilung, Standort, Sprache, etc nur im HR Tool pflegen. Allerdings wollen wir diese in unser AD synchronisieren. Bisher wurde das bereits gemacht, allerdings unregelmässig, mit einem script das manuell mit daten gefüttert und ausgeführt werden musste. Dies führt zu inkosistenzien und ist unnötig aufwendig. Ausserdem wird es dardurch nicht wirklich aktuell gehalten und es wurden nicht alle benötigten daten Synchronisiert.

**Welche Benutzer-Daten werden Synchronisiert?** 
- EmployeeID: ID auss SwissSalary
- Surname
- Firstname
- UserPrincipalName: E-Mail-Adresse bzw. UPN in der AD (sollte gleich sein). **Wird nicht aktiv angepasst, in zukunft soll bei änderung aber ein Alert & Ticket ausgelöst werden**
- Initials
- DepartmentCode
- JobTitel
- Division: Abteilungs-ID (Nummer aus SwissSalary)
- DepartmentDescription: Abteilungsname
- LanguageCode: Drei stelliger Sprachcode -> wird in extensionAttribute2 abgefüllt
- PostalCode: Bezug auf Anstellungsstandort
- City: Bezug auf Anstellungsstandort
- CountryCode: Bezug auf Anstellungsstandort
- StreetAdress: Bezug auf Anstellungsstandort
- State: Bezug auf Anstellungsstandort
- Company: "HEKS/EPER" (nicht hardcoded aber überall gleich)
- CountryFullname: Bezug auf Anstellungsstandort
- CountryNumeric: wird durch kleine funktion generiert. Entspricht codes die von Microsoft für das dropdownmenu in der AD verwendet werden und müssen mit-angepasst werden.

> PS: wo es selbstverständlich ist, habe ich keine erklärung hinzugefügt

### Ablauf / Flow

Hier eine grobe übersicht des Ablaufs:

1. Daten werden von HR in Swiss Salary (BC backend) angepasst
2. PowerBI Dataflow erstellt Report aller aktiven user + Abteilungen
3. PowerBi Reports werden als CSV in DataLake Gen2 Storage (az storage account) abgespeichert
4. Einmal täglich wird das Runbook "Get-PBIUserData" ausgelöst. Dieses holt die Daten aus dem Storage Account, transformiert sie in Json und löst ein neuen automation job mit dem Runbook "Update-UserdataLocalAD" auf dem Hybrid Worker aus.
5. Das Runbook "Update-UserdataLocalAD" wird auf dem Hybrid Runbook Worker ausgelöst. Dort vergleicht es die neuen Userdaten mit dem aktuellen Stand und Updated diese oder alarmiert entsprechend.
6. Das zweite runbook erstellt ebenfalls Logs und ein Backup CSV, welches zusammen mit einem weiteren Powershell Runbook verwendet werden kann um ein rollback auf den vorherigen zustand bzw auf einen der Backup CSV's auszuführen 

**Runbook "Get-PBIUserData"**

TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
Param(
    [string] $StorageAccountName = "hekspowerbiazsync",
    [string] $ContainerName      = "powerbi",
    [string] $BasePath           = "AzureADSync/SwSal Employee AD Export/Employees.csv.snapshots",
    [string] $ExportPath         = "EmployeeExport",
    [string] $ResourceGroupName  = "RG-AzAutomation-Main-Dev",
    [string] $AutomationAccount  = "Main-Test",
    [string] $HybridGroup        = "Main-Test-HybridWorker01",
    [string] $RunbookToStart     = "Update-UserdataLocalAD",
    [bool] $TestMode             = $false,
    [bool] $TestModeAdvanced     = $false
)

## ------- functions -------
function Get-CountryDetails { # TODO - improve function
    param(
        [string]$CountryCode
    )

    # Get Region Name (for Ad Atrribute 'co')
    $region = [System.Globalization.RegionInfo]::new($CountryCode)
    $fullName = $region.EnglishName

    # Get Region Numeric code (for Ad Atrribute 'countryCode') 
    $country = Get-BiaCountryByAlpha2 $CountryCode

    # Prepare results object
    $countryDetails = @{
        CountryName     = $fullName
        CountryNumeric  = $country.Numeric
    }
 
    return $countryDetails
}

## ------- Definitions -------

# Export Path
$timestamp        = Get-Date -Format "yyyy-MM-dd_HHmmss"
$exportFilePath   = "$ExportPath/employees-$timestamp.json"
$tempJsonFilePath = Join-Path $env:TEMP 'tempJsonFilePath'

# Define a local temp path 
$tempCsvFile = Join-Path $env:TEMP 'Employees.csv'

# Authentication for Az Storage Access
Disable-AzContextAutosave -Scope Process
$azureContext = (Connect-AzAccount -Identity).Context
Set-AzContext -SubscriptionName $azureContext.Subscription -DefaultProfile $azureContext

# set context for az Storage Access 
$storageContext = (New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount)

# set Colum names for csv import
$columnNames = @(
    'EmployeeID',
    'Surname',
    'Firstname',
    'UserPrincipalName',
    'Initials',
    'DepartmentCode',
    'JobTitel',
    'Division',
    'DepartmentDescription',
    'LanguageCode',
    'PostalCode',
    'City',
    'CountryCode',
    'StreetAdress',
    'State',
    'Company'
)

## ------- Retrieve and Prepare Data from PowerBi -------

# Get all blobs/files
try{
    $allBlobs = Get-AzStorageBlob -Container $ContainerName -Context $storageContext -Prefix $BasePath

} catch {
    throw "Error, couldn't get Data Blobs. Eror Message: $_"
}

if (-not $allBlobs) {
    throw "No blobs found under prefix '$BasePath'"
}

# Filter out the parent folder blob
$fileBlobs = $allBlobs | Where-Object { $_.Length -ne 0 }

# get latest file
$latest = $fileBlobs |
    Sort-Object { $_.BlobProperties.LastModified } -Descending |
    Select-Object -First 1

Write-Output "Using blob: $($latest.Name) (LastModified: $($latest.BlobProperties.LastModified))"

# Download CSV File into temp Folder   # TODO - try catch
Get-AzStorageBlobContent -Container $ContainerName -Blob $latest.Name -Destination $tempCsvFile -Context $storageContext -Force

# Import downloaded CSV File
$EmployeeList = Import-Csv $tempCsvFile -Header $columnNames

# Edit Employe Country data 
foreach ($employee in $EmployeeList){ # TODO - try catch?
    $countryDetails = Get-CountryDetails -CountryCode ($employee.CountryCode)

    $employee | Add-Member -MemberType NoteProperty -Name 'CountryFullname' -Value $countryDetails.CountryName
    $employee | Add-Member -MemberType NoteProperty -Name 'CountryNumeric' -Value $countryDetails.CountryNumeric
}

# TODO - Add e-mail Propertie from Data

# convert to Json for Ouput
$jsonData = $EmployeeList | ConvertTo-Json -Depth 10

# Save json to local temp file
Set-Content -Path $tempJsonFilePath -Value $jsonData -Encoding UTF8

# Save JsonFile to Storage account
try {
    Set-AzStorageBlobContent `
    -File       $tempJsonFilePath `
    -Container  $ContainerName `
    -Blob       $exportFilePath `
    -Context    $storageContext `
    -Force

} catch {
    Write-Output "Error. Could not save Json file to StorageAccount. Error Message: `n" + $_
}

# ------- Start AD Sync Runbook on Hybrid Worker -------

if (-not $TestMode){
    # Set Testmode Parameter & Pass Json data
    $childParams = @{
        'JsonFilePath' = $exportFilePath
        'TestMode' = $TestModeAdvanced
    }

    # Start the Hybrid runbook
    $job = Start-AzAutomationRunbook `
    -ResourceGroupName   $ResourceGroupName `
    -AutomationAccountName $AutomationAccount `
    -Name                $RunbookToStart `
    -Parameters          $childParams `
    -RunOn               $HybridGroup

    Write-Output $job

    # Wait for Hybrid Runbook
    do {
        Start-Sleep -Seconds 60
        $status = (Get-AzAutomationJob -ResourceGroupName $ResourceGroupName `
                                    -AutomationAccountName $AutomationAccount `
                                    -Id $job.Id).Status
        Write-Verbose "Hybrid job status: $status"
    } while ($status -in 'New','Running','Queued')

} else { # Default testmode
    Write-Output $jsonData
}

```

**Runbook "Update-UserdataLocalAD"**

> PS: Dieses script wird auf dem Hybrid Runbook worker ausgeführt

TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
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

```

**Runbook "Start-RollbackFromBackupCSV"**

> PS: Dieses script wird auf dem Hybrid Runbook worker ausgeführt

TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
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
$requiredModules = @(
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
}

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

```


## Mail Distribution List Generation & Updates

Bei diesem Artefakt dient der erstellung der automatisch befüllten Mailverteilerlisten. Dies war der Ursprung des Projekts. Es wurde gewünscht, dass neue Mitarbeiter automatisch in die entsprechenden Mailverteiler befüllt werden und diese somit nicht mehr von den jeweiligen Abteilungsleiterinnen gepflegt werden müssen.

Dabei soll der Mailverteiler einer Abteilung, immer auch alle user der Sub-Abteilungen beinhalten. Deshalb ist auch der "ParentCode" in den Abteilungsdaten angegeben. Dadurch kann das script, alle subabteilungen finden und die Query für den Mailverteiler entsprechend um deren Abteilungscodes erweitern

Zuerst hatte ich die Queries mit einem custom advanced filter erstellt. Allerdings stellte sich in der Pilotphase raus, dass dadurch die zugewiesenen user nicht eingesehen werden können.
Ich habe es nun umgestellt sodass es sogennante "Precanned" filter nutzt. Dies sind von Microsoft vordefinierte filterfunktionen. Die GUI funktioniert nur korrect, wenn diese Filterfunktionen verwendet werden. 
Das funktioniert nun auch, allerdings nur wenn ich einen einzelnen Abteilungscode verwende. Scheinbar müsste ich mehrere abteilungscodes mit Commas trennen können um mehrere Abteilungscodes abfragen zu können, dies klappt in der realität aber noch nicht so ganz.

Dieses Problem werde ich im nächsten Sprint angehen. Dies ist jedoch dann nach abschluss der Semesterarbeit und nicht mehr teil des Scopes. 

> Dieses Script wird auf dem Hybrid Runbook worker ausgeführt, da das Exchange Online Modul ein Kompatibilitätsproblem mit Azure Automation hat. Es kann sich allerdings einfach vom Server (Hybrid Runbook Worker) aus mit der Managed Identity an Exchange online authentifizieren.

### Ablauf / Flow

Hier eine grobe übersicht des Ablaufs:
1. Das Script holt sich die zuletzt aktualisierten Daten der Abteilungsliste die auf dem Azure Storage Account abgelegt ist. (Im moment sind das die Daten aus PowerBI, werde es aber noch anpassen, damit es sich die Daten aus der MS List holt, da wie erwähnt die Abteilungen in Swiss Salary nicht sauber geführt sind).
2. Das Script bereit alle benötigten Parameter vor
3. Das Script iteriert über alle subabteilungen einer abteilung und bereitet dadurch die entsprechende query für jede Abteilung vor.
4. Das script vergleicht die aktuell existierenden Mailverteiler mit den Daten und erfasst, ob die Mailverteiler bereits erstellt wurden. Falls nicht erstellt es die Mailverteiler neu.
5. Falls die Mailverteiler bereits existieren aber änderungen in den Daten verzeichnet sind, wird es die Mailverteiler entsprechend anpassen

> Note: Das script wird warhscheinlich einmal täglich ausgeführt. Allerdings ist das noch nicht abgeklärt da es noch nicht so relevant ist.

**Runbook "Generate-DepartmentGroups"**
TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
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
```

### Geplante Änderungen

Das Script heisst aktuel "Generate-DepartmentGroups" da es ursprunglich dazu gedacht war Mailverteiler und Security Groups für Abteilungen zu erstellen. Allerdings fallen die Security Groups wie bereits erwähnt weg und somit wird es umbenannt und angepasst um nur mailverteiler für Abteilungen zu erstellen.

Ausserdem werde ich das Problem mit der Abfrage mehrerer Abteilungscodes noch angehen. Gemäss Microsofts eigener Dokumentation auf learn.microsoft.com, sollte es möglich sein mehrere Values mitzugeben. Es sollte also lösbar sein.
Danach sollten auch die user entsprechend richtig angezeigt werden.

## Asset Assigment Handling

Beim dritten Artefakt, geht es darum, die Asset zuweisung zu handhaben. Hierfür haben wir die beiden MS Listen die miteinander verknüpft sind. Wenn in der Abteilungsliste ein Asset an eine Abteilung zugewiesen wird, wird entsprechend ein script ausgelöst, dass diese zuweisung vornimmt.

Dabei werden die Daten zuerst bei jeglichen Updates in der MS List durch eine Logic App in ein Azure Storage Account synchronisiert.

Später wenn das script läuft (läuft in regelmässigen zyklus durch z.b einmal am tag), überprüft das script ob Asset zuweisungen verändert wurden. Falls ja erstellt es eine neue Query für das entsprechende Asset, welches die Abteilungen entfernt/hinzufügt. 

Die user werden dann durch die Query automatisch der Dynamischen Asset Gruppe (achtung Asset gruppe ist meine persönliche bezeichnung dafür. Hier geht es um eine Dynamische Azure Security Group) zugewiesen und erhalten somit die freigabe für das Asset (also z.B acces auf eine Site oder App oder eine bestimmte lizenz wird zugewiesen etc.).

### Storage Account Container "manualdb"

Weil das ganze projekt noch im Anfangsstadium ist, habe ich der einfachheithalber den gleich storage account weiterverwendet wie für PowerBI. Ich habe allerdings einen zweiten Container darin erstellt und ihn "manualdb" bennant. Dies wird später noch angepasst.

Darin befinden sich 3 Directories. Eine für den Assets Catalog, eine für die unverarbeiteten Daten aus dem Department Inventory und eine für die bereinigten Abteilungsdaten.

Die Logic App und der Automation Account haben beide über ihre jeweiligen Managed Identity Schreibzugriff auf dem Storage Account.

TODO - Bild der struktur im storage account einfügen

### Logic App - MS List zu Storage Account Synchronisieren

Für diesen Simplen Prozess habe ich mich entschieden eine Logic App statt einem Runbook zu verwenden, da ich ansonsten HTTPS requests über das MS Graph interface hätte machen müssen, was vorallem die Berechtigungslage unnötig verkompliziert hätte.

Stattdessen habe ich einen Service User erstellt, welcher Leseberechtigungen auf der ICT Site hat, auf der die beiden MS Lists gespeichert sind (später können diese Berechtingungen allenfalls noch weiter eingeschränkt werden). Dann habe ich diesen im Connector hinterlegt. 

Das passwort für den Benutzer wird irgendwann auslaufen und muss erneuert werden. Hierfür muss ich mir noch eine Lösung überlegen. Allerdings hatte da eine niedrigere priorität und ich hatte leider keine Zeit mehr dies zu lösen.

**Ablauf / Flow**
Hier eine grobe übersicht des Ablaufs der Logic App:
1. Connector erkennt änderung an MS List und triggered die Logic App
2. Logic App hat zwei Parallele Abläufe die ausgelöst werden
    - Der erste Ablauf convertiert die Daten des Asset Katalogs direct in JSON und speichert diese als Blob im Storage account.
    - Der zweite Ablauf convertiert die Daten nur soweit wie möglich aus der Department List. Einige felder mit verschachtelten werden wie z.B die zugewiesenen Assets, können allerdings nicht so einfach convertiert werden. Deshalb speichert es die Daten als JSON in einer separaten Directory im Container im Storage account als "RAW" Daten.
3. Ein Automation Job wird ausgelöst, welcher das Runbook "LogicAppHelper-SimplifyDepartmentsData" startet.
4. Das Helper Runbook, holt sich die zuletzt aktualisierten Daten aus dem Storage account
5. Es filtert die benötigten daten raus und generiert ein "cleaned" JSON.
6. Das JSON wird dann im Storage account in der Directory "Departments" abgelegt.

TODO - Bild von Logic app einfügen


**Runbook "LogicAppHelper-SimplifyDepartmentsData"**
TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
Param(
    [string] $StorageAccountName = "hekspowerbiazsync",
    [string] $ContainerName      = "manualdb",
    [string] $BasePath           = "DepartmentsRAW",
    [string] $ExportPath         = "Departments"
)

## ---------------------------- Environment ------------------------------------------------
$ErrorActionPreference = 'Stop'

# Disable coloured output for the whole runbook - this makes for more readable runbook outputs
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText

## ---------------------------- Get JSON Data ------------------------------------------------

# Export Path
$timestamp        = Get-Date -Format "yyyy-MM-dd_HHmmss"
$exportFilePath   = "$ExportPath/departments_$timestamp.json"
$tempJsonFilePath = Join-Path $env:TEMP 'tempJsonFilePath'

# Define a local temp path 
$tempJsonFile = Join-Path $env:TEMP 'DepartmentsData.json'

# Authentication for Az Storage Access
Disable-AzContextAutosave -Scope Process
$azureContext = (Connect-AzAccount -Identity).Context
Set-AzContext -SubscriptionName $azureContext.Subscription -DefaultProfile $azureContext

# set context for az Storage Access 
$storageContext = (New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount)

# Get all blobs/files
try{
    $allBlobs = Get-AzStorageBlob -Container $ContainerName -Context $storageContext -Prefix $BasePath

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

# Download JSON File into temp Folder   # TODO - try catch
Get-AzStorageBlobContent -Container $ContainerName -Blob $latest.Name -Destination $tempJsonFile -Context $storageContext -Force

# Import downloaded JSON File
$Departmentlist = Get-Content -Raw -Path $tempJsonFile | ConvertFrom-Json

<# Write-Output "RAW Departmentlist: "
Write-Output $Departmentlist #>

### --------------------------- Cleanup Data ----------------------------------

<# # Unescape the JSON string to handle escape characters
$unescapedJson = [System.Text.RegularExpressions.Regex]::Unescape($Departmentlist)

# Clean the JSON string
$cleanedJson = $unescapedJson.Replace('@odata','odata') #>

<# Write-Output "Cleaned JSON: "
Write-Output $cleanedJson #>

<# $Departments = ConvertFrom-Json $Departmentlist # TODO - changed to not replace or escape

Write-Output "Department List"
Write-Output $Departments #>

$result = @()

foreach ($item in $Departmentlist) {
    # ApprovedbyIT → Value (or null)
    $approved = if ($item.ApprovedbyIT -and $item.ApprovedbyIT.Value) {
        $item.ApprovedbyIT.Value
    } else {
        $approved = "NO"  # Default to NO, to prevent mistakenly creating Departments
    }

    # AssignedAssets → comma-joined string of each .Value
    if ($item.AssignedAssets -and ($item.AssignedAssets -is [System.Collections.IEnumerable])) {
        $assignedAssets = ($item.AssignedAssets | ForEach-Object { $_.Value }) -join ','
    } else {
        $assignedAssets = '' # TODO -> Create error & handle empty fields
    }

    # AssignedAssetsSecurityGroups → same for the security array
    $secPropName = 'AssignedAssets_x003a__x0020_Secu'
    if ($item.PSObject.Properties.Name -contains $secPropName `
        -and ($item.$secPropName -is [System.Collections.IEnumerable])) {
        $assignedAssetsSec = ($item.$secPropName | ForEach-Object { $_.Value }) -join ','
    } else {
        $assignedAssetsSec = '' # TODO -> Create error & handle empty fields
    }

    # Build the PSCustomObject
    $dept = @{
        Title                             = $item.Title
        DepartmentCode                    = $item.DepartmentCode
        ParentCode                        = $item.ParentCode
        SpecialCodes                      = $item.SpecialCodes
        Approved                          = $approved
        AssignedAssets                    = $assignedAssets
        AssignedAssetsSecurityGroups      = $assignedAssetsSec
    }

    Write-Output "Department X"
    Write-Output $dept

    $result += $dept
}

$CleanDataJson = $result | ConvertTo-Json -Depth 5

Write-Output "Cleaned and Rebuild JSON: "
Write-Output $CleanDataJson

# Save json to local temp file
Set-Content -Path $tempJsonFilePath -Value $CleanDataJson -Encoding UTF8

# Save JsonFile to Storage account
try {
    Set-AzStorageBlobContent `
    -File       $tempJsonFilePath `
    -Container  $ContainerName `
    -Blob       $exportFilePath `
    -Context    $storageContext `
    -Force

} catch {
    Write-Output "Error. Could not save Json file to StorageAccount. Error Message: `n" + $_
}

```

### Assignment Logic Ablauf / Flow

Hier eine grobe übersicht des Ablaufs:
1. Daten auf der MS List werden geändert und Logic App synchronisiert die Daten in den Storage Account
2. Einmal täglich wird das "Update-AssetAssignments" Script gestartet
3. Das script holt sich die zuletzt aktualisierten Daten aus dem Storage Account
4. Es erstellt eine Liste aller Assets und welche Abteilungen in der Query vorhanden sein müssen.
5. Dann übeprüft es den aktuellen zustand der Queries und vergleicht diese mit den neuen Daten.
6. Falls änderungen gefunden werden, passt es die Queries der Asset Groups entsprechend an.

**Runbook "Update-AssetAssignments"**

TODO - an CHATGPT - füge hier eine knappe beschreibung des scripts hinzu

```PowerShell
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

```


## Self Service

TODO - erstelle hier eine kurze beschreibung aus den infos die du bisher hast

## Logging & Auditing - TODO -> not sure where to put this - TODO less prio 

TODO - beschreibe hier das ich alerting für failed runbooks und logic app erstellen möchte, dies leider zeitlich nicht mehr möglich war bisher. ich werde das nachholen