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
