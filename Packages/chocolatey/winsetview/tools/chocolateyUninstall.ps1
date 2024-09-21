$ErrorActionPreference = 'Stop';

Write-Host $env:ChocolatePackageName
$packageDirectory = Join-Path $env:ChocolateyInstall "lib\winsetview"
Write-Host $packageDirectory

if (Test-Path $packageDirectory) {
  Remove-Item $packageDirectory -Recurse -Force
}
