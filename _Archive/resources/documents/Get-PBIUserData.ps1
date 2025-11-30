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
