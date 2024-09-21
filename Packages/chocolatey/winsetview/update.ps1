
param (
  [Parameter(Mandatory=$true)][string]$version,
  [Parameter(Mandatory=$true)][string]$rootPath
)

$ErrorActionPreference = 'Stop'

function UpdateRawXMLProperty {
  param (
    [Parameter(Mandatory=$true)][string]$xmlContent,
    [Parameter(Mandatory=$true)][string]$property,
    [Parameter(Mandatory=$true)][string]$value
  )

  $xmlContent = $xmlContent -replace "(\s*)(\<$property\>)[\S\s]*(\</$property\>)", "`${1}`${2}$($value)`$3"
  Write-Output $xmlContent
}

$currentPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Get nuspec content
$nuspecPath = Join-Path $currentPath "winsetview.nuspec"
[xml]$nuspecContentXML = Get-Content $nuspecPath
$newNuspecContent = Get-Content $nuspecPath -Raw

# Update version
if ($version) {
  $currentVersion = $nuspecContentXml.package.metadata.version
  $newNuspecContent = UpdateRawXMLProperty -xmlContent $newNuspecContent -property "version" -value $version
  Write-Host "Updating nuspec version: $currentVersion -> $version"
}

# Update description
$descriptionPath = Join-Path $currentPath "Description.md"
$descriptionContent = Get-Content $descriptionPath -Raw
$newDescription = ($descriptionContent -split "`n" | Select-Object -Skip 1) -join "`n"
$newDescription = "<![CDATA[$newDescription]]>"
$newNuspecContent = UpdateRawXMLProperty -xmlContent $newNuspecContent -property "description" -value $newDescription
Write-Host "Updating nuspec description from $descriptionPath"

# Update verification
$verificationPath = Join-Path $currentPath "legal\VERIFICATION.txt"
$exePath = Join-Path $rootPath "WinSetView.exe"
$exeHash = (Get-FileHash -Path $exePath -Algorithm SHA256).Hash
$verificationTemplateContent = Get-Content(Join-Path $currentPath "VERIFICATION.template.txt") -Raw
$verificationTemplateContent = $verificationTemplateContent -replace "{{VERSION}}", $version -replace "{{CHECKSUM}}", $exeHash
Write-Host "Updating verification file with version $version and checksum $exeHash"

# Write files
Set-Content -Path $nuspecPath -Value $newNuspecContent -NoNewline
Set-Content -Path $verificationPath -Value $verificationTemplateContent
