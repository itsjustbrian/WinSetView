
$ErrorActionPreference = 'Stop'

$currentPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$nuspecPath = Join-Path $currentPath "winsetview.nuspec"
[xml]$nuspecXml = Get-Content $nuspecPath

$version = $nuspecXml.package.metadata.version
Write-Host "Building verion $version from nuspec $nuspecPath"

$zipFileName = "WinSetView-$version.zip"
$zipFilePath = Join-Path $currentPath "tools" $zipFileName

$assetUrl = "https://github.com/LesFerch/WinSetView/archive/refs/tags/$version.zip"
Write-Host "Downloading release: $assetUrl"
Invoke-WebRequest $assetUrl -OutFile $zipFilePath
Write-Host "Saved release: $zipFilePath"

choco pack $nuspecPath --out $currentPath --limit-output | Out-Host

if (Test-Path $zipFilePath) {
  Remove-Item $zipFilePath -Force
}

$package = Get-ChildItem -Path $currentPath -Filter *.nupkg | Select-Object -First 1
if (!$package) {
  throw ('No nupkg file was found after build in {0}' -f $currentPath)
}

Write-Output $package
