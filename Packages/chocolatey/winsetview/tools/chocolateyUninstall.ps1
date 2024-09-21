$ErrorActionPreference = 'Stop';

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Try removing exe first to error out early if there is a problem
# like WinSetView currently running
$exePath = Join-Path $toolsDir "WinSetView.exe"
Remove-Item -Path $exePath -Force

$packageDirectory = Join-Path $env:ChocolateyInstall "lib\winsetview"
if (Test-Path $packageDirectory) {
  Remove-Item $packageDirectory -Recurse -Force
}
