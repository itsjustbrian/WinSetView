
param (
  [Parameter(Mandatory=$true)][string]$version,
  [Parameter(Mandatory=$true)][string]$exePath
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

$nuspecPath = Join-Path $currentPath "winsetview.nuspec"
[xml]$nuspecContentXML = Get-Content $nuspecPath
$newNuspecContent = Get-Content $nuspecPath -Raw

if ($version) {
  $currentVersion = $nuspecContentXml.package.metadata.version
  $newNuspecContent = UpdateRawXMLProperty -xmlContent $newNuspecContent -property "version" -value $version
  Write-Host "Updating nuspec version: $currentVersion -> $version"
}

$descriptionPath = Join-Path $currentPath "Description.md"
$descriptionContent = Get-Content $descriptionPath -Raw
$newDescription = ($descriptionContent -split "`n" | Select-Object -Skip 1) -join "`n"
$newDescription = "<![CDATA[$descriptionContent]]>"
$newNuspecContent = UpdateRawXMLProperty -xmlContent $newNuspecContent -property "description" -value $newDescription
Write-Host "Updating nuspec description from $descriptionPath"

$exeHash = (Get-FileHash -Path $exePath -Algorithm SHA256).Hash
$verificationPath = Join-Path $currentPath "legal/VERIFICATION.txt"
$verificationContent = Get-Content $verificationPath -Raw
$verificationPath = $verificationContent -replace '\b(checksum: ).*\b', "`$1$exeHash"
Write-Host "Updating verification checksum: $exeHash"

Set-Content -Path $verificationPath -Value $verificationContent -NoNewline
Set-Content -Path $nuspecPath -Value $newNuspecContent -NoNewline
