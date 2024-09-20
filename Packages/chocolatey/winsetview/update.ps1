
param (
  [string]$version
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
  Write-Host "Updated version: $currentVersion -> $version"
}

$descriptionPath = Join-Path $currentPath "Description.md"
$descriptionContent = Get-Content $descriptionPath -Raw
$newDescription = ($descriptionContent -split "`n" | Select-Object -Skip 1) -join "`n"
$newDescription = "<![CDATA[$descriptionContent]]>"
$newNuspecContent = UpdateRawXMLProperty -xmlContent $newNuspecContent -property "description" -value $newDescription
Write-Host "Updated description from $descriptionPath"

Set-Content -Path $nuspecPath -Value $newNuspecContent -NoNewline
