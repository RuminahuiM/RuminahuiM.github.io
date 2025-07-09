---
layout: default
title: Produkte / Artefakte
parent: 3. Projektdurchführung
nav_order: 2
---

{: .no_toc }

# Produkte / Artefakte / Komponenten

Dieses Projekt besteht aus mehreren Artefakten, die jeweils eine eigene Funktionalität bereitstellen und unterschiedliche technische Komponenten nutzen.

## SwissSalary-zu-AD-Synchronisation

**Artefakt-Bezeichnung:** SwissSalary-to-AD Sync

Dieses Artefakt war ursprünglich nicht als Teil dieses Projekts geplant, hat sich jedoch als unverzichtbare Voraussetzung herausgestellt. Ziel ist es, die in SwissSalary (Business Central) verwalteten Mitarbeiterdaten—wie Abteilung, Standort und Sprache—regelmässig und vollständig in das lokale Active Directory zu übertragen. Bislang erfolgte der Abgleich manuell:

1. CSV-Export aus Business Central  
2. Manuelles Kopieren auf einen Server  
3. Ausführung eines PowerShell-Skripts mit den aktuellen Daten  

Diese Vorgehensweise führte zu Inkonsistenzen, hohem manuellem Aufwand und lückenhafter Datenaktualität, da nicht alle erforderlichen Attribute synchronisiert wurden.

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

> Hinweis: wo es selbstverständlich ist, habe ich keine erklärung hinzugefügt

### Ablauf / Flow

Nachfolgend eine strukturierte Übersicht des Prozessablaufs:

1. **Datenpflege im HR-System**  
   Die HR-Verantwortlichen passen Mitarbeiterattribute (z. B. Abteilung, Standort, Sprache) in SwissSalary (Business Central) an.  
2. **Erzeugung des Power BI-Reports**  
   Ein Dataflow in Power BI erstellt täglich einen Report aller aktiven Benutzer und deren Abteilungszuordnung.  
3. **Persistierung im Data Lake**  
   Die Power BI-Reports werden automatisch als CSV-Dateien im Azure Data Lake Gen2 (Storage Account) abgelegt.  
4. **Start des Runbooks "Get-PBIUserData"**  
   Ein geplanter Trigger im Azure Automation Account löst einmal täglich das Runbook **Get-PBIUserData** aus.  
   - Liest die neuesten CSVs aus dem Storage Container ein  
   - Wandelt die Daten in JSON um  
   - Startet das zweite Runbook **Update-UserdataLocalAD** auf dem Hybrid Runbook Worker  
5. **AD-Aktualisierung auf dem Hybrid Worker**  
   Das Runbook **Update-UserdataLocalAD** vergleicht die JSON-Daten mit dem aktuellen lokalen AD-Zustand und:  
   - Aktualisiert geänderte Attribute  
   - Protokolliert Abweichungen und wirft bei kritischen Änderungen Alarme  
6. **Backup & Rollback-Vorbereitung**  
   Parallel zur Aktualisierung werden Logs und eine Backup-CSV erzeugt. Eine spätere Rollback funktion kann anhand dieser Backup-Dateien den vorherigen AD-Zustand wiederherstellen.

**Runbook "Get-PBIUserData"**

Dieses PowerShell-Runbook lädt das aktuellste Employee-CSV-Snapshot aus einem Azure Storage Container (Power BI Export), reichert die Datensätze um Länderinformationen (Name und numerischer Code) an und konvertiert sie in ein JSON-Format. Anschliessend wird die JSON-Datei wieder in das Storage-Konto geschrieben und – sofern nicht im Testmodus – der nachgelagerte Runbook-Job Update-UserdataLocalAD auf einem Hybrid Worker gestartet, um die lokalen AD-Attribute der Benutzer zu aktualisieren. Parameter ermöglichen die Anpassung von Storage- und Runbook-Kontext, Pfaden sowie Testmodi.

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

Dieses PowerShell-Runbook wird lokal auf einem Hybrid Worker ausgeführt und liest die JSON-Datei mit den Benutzerattributen aus Azure Storage ein. Es stellt sicher, dass alle benötigten PowerShell-Module (ActiveDirectory, Az.Accounts, Az.Storage) verfügbar sind, sichert bestehende AD-Benutzerdaten in einer Backup-CSV, und vergleicht dann pro Benutzer die eingehenden Werte mit den aktuellen AD-Attributen. Abweichungen werden protokolliert und – ausserhalb des Testmodus – direkt mit Set-ADUser in Active Directory übernommen. Zusätzlich werden alte Log- und Backup-Dateien automatisch anhand einer einstellbaren Aufbewahrungsdauer bereinigt.

> Hinweis: Dieses script wird auf dem Hybrid Runbook worker ausgeführt

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

Dieses PowerShell-Runbook stellt Active-Directory-Attribute anhand einer zuvor erstellten Backup-CSV wieder her. Es sichert die benötigten AD-Module, lädt die Backup-Datei aus dem lokalen Backup-Verzeichnis, und vergleicht für jeden Eintrag die aktuellen AD-Werte mit den gesicherten Werten. Abweichungen werden protokolliert und – ausserhalb des Testmodus – über Set-ADUser zurückgesetzt. Parallel dazu wird ein Transkript geführt und alte Logdateien automatisch verwaltet.

> Hinweis: Dieses script wird auf dem Hybrid Runbook worker ausgeführt

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

Bei diesem Artefakt steht die automatische Erstellung und Pflege der abteilungsbezogenen Mailverteilerlisten im Mittelpunkt. Ziel ist es, neue Mitarbeitende automatisch in die jeweils zuständigen Verteiler aufzunehmen und die manuelle Pflege durch Abteilungsleitungen zu entlasten.

- Jeder Mailverteiler (`<DeptCode>_DL`) einer Abteilung enthält auch alle Benutzer der zugehörigen Sub-Abteilungen.  
- Der `ParentCode` in der Abteilungsdefinition ermöglicht es, alle Sub-Abteilungen dynamisch zu ermitteln und deren Codes in die Filterabfrage aufzunehmen.

Ursprünglich nutzte ich für die Queries einen benutzerdefinierten Advanced-Filter. In der Pilotphase wurde jedoch deutlich, dass damit keine Mitglieder in der GUI angezeigt werden können. Daraufhin stellte ich auf die von Microsoft vordefinierten **"Precanned"** Filter um. Diese bieten GUI-Kompatibilität und funktionieren zuverlässig – allerdings aktuell nur für einzelne Abteilungscodes. Die Kombination mehrerer Codes mit Komma-Trennung klappt derzeit nicht vollständig und wird nach Abschluss der Semesterarbeit weiter optimiert.

> Hinweis: Dieses Runbook läuft auf dem Hybrid Runbook Worker, da das Exchange Online PowerShell-Modul in Azure Automation nicht vollständig unterstützt wird. Die Authentifizierung erfolgt unkompliziert über die System Managed Identity des Servers.

### Ablauf / Flow

1. **Lesen der Abteilungsdaten**  
   Das Script lädt die aktuellste Abteilungsliste aus dem Azure Storage Account (derzeit Power BI-CSV, zukünftig MS List).  
2. **Parameter-Vorbereitung**  
   Vorlage aller notwendigen Filterparameter für jede Abteilung.  
3. **Sub-Abteilungen ermitteln**  
   Ermitteln aller Sub-Abteilungen anhand des `ParentCode` und Zusammenstellung der Codes.  
4. **Vergleich & Neuanlage**  
   Abgleich vorhandener Verteilerlisten mit den berechneten Filtern – bei fehlenden Listen erfolgt die Neuanlage.  
5. **Aktualisierung bestehender Verteiler**  
   Bei Änderungen in den Abteilungsdaten passt das Script die Filter der bereits bestehenden Verteiler entsprechend an.  

> Hinweis: Die genaue Ausführungsfrequenz (z. B. täglich) wird derzeit noch abgestimmt und ist nicht zwingend Teil des aktuellen Projektumfangs.


**Runbook "Generate-DepartmentGroups"**

Dieses PowerShell-Runbook liest eine CSV mit Abteilungs-Codes und deren Hierarchie aus einem Azure Storage Container ein, baut daraus eine strukturierte Abteilungs-Tabelle inklusive Eltern-Kind-Beziehungen und Sonder-Codes auf und verbindet sich anschliessend per Managed Identity mit Exchange Online. Für jede Abteilung wird ein hierarchischer Alias generiert (z. B. dl_srv_ict_sys), ein entsprechender SMTP-Filter aller zugehörigen Codes erstellt und dann über die Exchange-Cmdlets entweder eine neue Dynamic Distribution Group angelegt oder eine bestehende aktualisiert. Mit den Parametern TestMode und Force lassen sich gefahrlos Tests durchführen und Alt-Objekte umbenennen, bevor die finale Erstellung bzw. Aktualisierung in der Produktivumgebung erfolgt.

> Hinweis: Dieses Runbook wird auf dem Hybrid Runbook Worker ausgeführt

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

Das Runbook heisst aktuell **"Generate-DepartmentGroups"**, da es ursprünglich sowohl Mailverteiler als auch Sicherheitsgruppen für Abteilungen anlegen sollte. Da die Security-Groups nun entfallen, wird das Skript entsprechend umbenannt und auf die reine Erstellung von Mailverteilern fokussiert (z. B. **"Generate-DistributionLists"**).

Ein weiterer geplanter Schritt ist die Lösung des Problems bei der Abfrage mehrerer Abteilungscodes. Microsofts Dokumentation auf learn.microsoft.com weist darauf hin, dass dynamische Gruppen-Abfragen mehrere Werte per Komma unterstützen sollten. Nach Abschluss der Semesterarbeit werde ich die Filterlogik anpassen und testen, so dass auch kombinierte Abteilungscodes korrekt verarbeitet und in der GUI angezeigt werden.

## Asset Assignment Handling

Beim dritten Artefakt geht es um die automatische Zuweisung von Digital Assets. Dazu werden die beiden Microsoft Lists in SharePoint ("Departments Inventory" und "Digital Assets Catalog") genutzt. Sobald in der Departments Inventory ein Asset einer Abteilung zugewiesen wird, löst ein Skript die entsprechende Zuweisung aus:

1. Eine Logic App synchronisiert Änderungen aus beiden MS Lists in einen Blob-Container des Azure Storage Accounts.  
2. Ein Runbook (z. B. täglich) prüft, ob sich Zuweisungen geändert haben, und erstellt bei Bedarf eine neue Filter-Query für die jeweilige Asset-Gruppe.  
3. Benutzer werden automatisch der dynamischen Azure AD Security Group zugewiesen, die das Asset repräsentiert (z. B. Zugriff auf eine Site, eine App oder eine Lizenz).

### Storage Account Container "manualdb"

Für den Zwischenschritt im Self-Service- und Automatisierungs-Workflow wurde im bestehenden ADLS Gen2 Storage Account ein zusätzlicher Container **`manualdb`** angelegt mit drei Verzeichnissen:

- **AssetsCatalog**: JSON-Export des Digital Assets Catalog  
- **DepartmentsRAW**: Rohdaten der Departments Inventory (unverarbeitet)  
- **Departments**: Bereinigte, normierte Abteilungsdaten  

Logic App und Automation Account greifen über ihre System Managed Identities auf diesen Container zu.

### Logic App – MS List zu Storage Account synchronisieren

Eine einzelne Logic App sorgt für die Datensynchronisation, um die Komplexität direkter REST-Aufrufe an die SharePoint-API zu vermeiden:

1. **Trigger:** Änderung in einer der beiden MS Lists  
2. **Parallele Flows:**  
   - **AssetsCatalog-Flow:** Wandelt neue Asset-Datensätze in JSON um und speichert sie in `manualdb/AssetsCatalog`.  
   - **DepartmentsRAW-Flow:** Exportiert die Departments Inventory als JSON in `manualdb/DepartmentsRAW`.  
3. **Nachgelagerter Automation Job:** Startet das Runbook **LogicAppHelper-SimplifyDepartmentsData**, das die RAW-Daten bereinigt und das Ergebnis in `manualdb/Departments` ablegt.

TODO - *Abb. X: Struktur des Containers "manualdb" und Ablauf der Logic App*  

**Runbook "LogicAppHelper-SimplifyDepartmentsData"**

Dieses PowerShell-Skript liest die rohe Departments-JSON aus einem Azure Storage-Container ein, bereinigt und transformiert die Daten (z. B. Zusammenführen von Asset-Arrays, Standardisierung des "ApprovedbyIT"-Werts, Trennung von Security-Gruppen), erzeugt daraus eine flache PSCustomObject-Struktur und schreibt das aufbereitete JSON mit Zeitstempel zurück in das Storage-Konto. Dabei sorgen einfache Parameter für die Konfiguration von Storage-Account, Container und Pfaden.

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

Hier eine grobe Übersicht des Ablaufs:

1. Änderungen in den MS Lists werden erkannt und durch die Logic App in den Storage Account synchronisiert.  
2. Einmal täglich wird das Runbook **Update-AssetAssignments** ausgelöst.  
3. Das Skript lädt die neuesten JSON-Dateien aus dem Storage Account.  
4. Es erstellt eine Liste aller Assets und ermittelt, welche Abteilungscodes in den Filter-Queries enthalten sein müssen.  
5. Es vergleicht die bestehenden Dynamic Group-Queries mit den neuen Vorgaben.  
6. Bei Abweichungen passt das Skript die Queries der jeweiligen Asset-Gruppen automatisch an.  


**Runbook "Update-AssetAssignments"**

Dieses PowerShell-Runbook lädt die bereinigten Department- und Asset-Katalog-JSONs aus Azure Storage, ermittelt anhand der freigegebenen DepartmentCodes, welche Sicherheitsgruppen ("Assets") für welche Abteilungen dynamische Membership-Regeln benötigen, und aktualisiert über Microsoft Graph (Get-MgGroup/Update-MgGroup) die membershipRule jeder Dynamic-Group entsprechend. Mit TestMode lassen sich die Regel-Änderungen zunächst per -WhatIf prüfen, bevor sie produktiv angewendet werden.

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

## Self-Service

Für Endanwender steht ein schlankes Self-Service-Interface in Microsoft Teams zur Verfügung. Über zukünftige MS Forms können berechtigte Personen und System Engineers können die Abteilungen verwalten:

1. **Neue Abteilungen anlegen**  
   - Direkte Pflege in der MS List "Departments Inventory"  
   - Auswahl benötigter Digital Assets über Dropdown aus dem "Digital Assets Catalog"  
   - Automatische Auslöse-Logik: Ein PowerShell-Runbook übernimmt nach Freigabe durch den System Engineer die Provisionierung (Mailverteiler, Asset-Gruppen)

2. **Individuelle Mailverteiler anfragen (noch nicht erstellt)**  
   - Formular-basierter Intake (MS Forms), eingebettet in SharePoint/Teams  
   - Automatisierter Genehmigungs-Workflow 
   - Nach Freigabe Anlage durch das "Generate-DistributionLists"-Runbook

3. **Übersicht und Statusabfrage**  
   - Echtzeit-Ansicht aller existierenden Mailverteiler und Asset-Gruppen  
   - Anzeige von Genehmigungs- und Provisionierungsstatus

Damit entfällt die manuelle Nachpflege durch Abteilungsleitungen, und alle Anfragen lassen sich nachvollziehbar dokumentieren und automatisiert abarbeiten.

## Logging & Auditing

Geplante Erweiterung:  
- **Alerting für fehlgeschlagene Runbook- und Logic App-Ausführungen** über Azure Monitor Alerts / Log Analytics  
- **Audit-Logs** aller wichtigen Schritte (Sync, Provisionierung, Asset-Zuweisung) in einem zentralen Log Analytics Workspace  

Aufgrund begrenzter Projektzeit konnte die vollständige Implementierung dieser Monitoring- und Alerting-Funktionalitäten bisher nicht realisiert werden. Nach Abschluss der Semesterarbeit wird ein entsprechendes Setup nachgeführt, um Betriebsstabilität und Compliance sicherzustellen.  
