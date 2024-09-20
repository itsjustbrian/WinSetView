
$ErrorActionPreference = 'Stop'

$currentPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$nuspecPath = Join-Path $currentPath "winsetview.nuspec"
[xml]$nuspecXml = Get-Content $nuspecPath

$version = $nuspecXml.package.metadata.version
Write-Host "Building verion $version from nuspec $nuspecPath"

# get current checksum from verification 
# create checksum from current exe
# compare and error out if different

$zipFileName = "WinSetView-$version.zip"
$zipFilePath = Join-Path $currentPath "tools" $zipFileName

git archive -o $zipFilePath HEAD
choco pack $nuspecPath --out $currentPath --limit-output | Out-Host
if (Test-Path $zipFilePath) {
  Remove-Item $zipFilePath -Force
}

$package = Get-ChildItem -Path $currentPath -Filter *.nupkg | Select-Object -First 1
if (!$package) {
  throw ('No nupkg file was found after build in {0}' -f $currentPath)
}

Write-Output $package
