
param (
  [string]$version,
  [string]$readMePath
)

$ErrorActionPreference = 'Stop'

function UpdateRawXMLProperty {
  param (
    [Parameter(Mandatory=$true)][string]$xmlContent,
    [Parameter(Mandatory=$true)][string]$property,
    [Parameter(Mandatory=$true)][string]$value
  )

  $xmlContent = $xmlContent -replace "(\<$property\>).*?(\</$property\>)", "`${1}$($value)`$2"
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
  $newReleaseNotes = "https://github.com/LesFerch/WinSetView/releases/tag/$version"
  $newNuspecContent = UpdateRawXMLProperty -xmlContent $newNuspecContent -property "releaseNotes" -value $newReleaseNotes
  Write-Host "Updated release notes: $newReleaseNotes"
}

if ($readMePath) {
  $readmeContent = Get-Content $readMePath -Raw
  # Remove the first line of the readme
  $newDescription = ($readmeContent -split "`n" | Select-Object -Skip 1) -join "`n`$1`t"
  # Replace description while keeping the formatting nice
  $newNuspecContent = $newNuspecContent -replace '\n(\s*)(\<description\>)[\S\s]*(\</description\>)', "`n`$1`$2`n`$1`t$newDescription`n`$1`$3"
  Write-Host "Updated description from README $readMePath"
}

Set-Content -Path $nuspecPath -Value $newNuspecContent -NoNewline
