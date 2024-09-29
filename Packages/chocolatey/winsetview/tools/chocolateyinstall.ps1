$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Find WinSetView archive
$zipFile = Get-ChildItem -Path $toolsDir -Filter "WinSetView*.zip" | Select-Object -First 1
if (-Not $zipFile) {
  throw ("No WinSetView zip file found in directory {0}" -f $toolsDir)
}

# Unzip archive
Get-ChocolateyUnzip -FileFullPath $zipFile.FullName -Destination $toolsDir

# Add auto shim exclusions
# https://docs.chocolatey.org/en-us/create/create-packages/#how-do-i-exclude-executables-from-getting-shims
$allExeFiles = Get-ChildItem -Path $toolsDir -Include *.exe -Recurse
foreach ($file in $allExeFiles) {
  New-Item "$file.ignore" -ItemType file -Force | Out-Null
}

# Make WinSetView.ps1 available on PATH as winsetview-cli
# Copied from https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Install-ChocolateyPowershellCommand.ps1
# but modified to allow a custom name for the command.
$winSetViewScript = Get-ChildItem -Path "$toolsDir\WinSetView.ps1"
$nugetPath = $(Split-Path -Parent $helpersPath)
$nugetExePath = Join-Path $nuGetPath 'bin'
$packageBatchFileName = Join-Path $nugetExePath "winsetview-cli.bat"

Write-Host "Adding $packageBatchFileName and pointing it to powershell command $winSetViewScript"

"@echo off
powershell -NoProfile -ExecutionPolicy unrestricted -Command ""& `'$winSetViewScript`'  %*"""| Out-File $packageBatchFileName -Encoding ASCII

# Make WinSetView.exe available on PATH as winsetview
$winSetViewExe = Get-ChildItem -Path "$toolsDir\WinSetView.exe"
Install-BinFile -Name "winsetview" -Path $winSetViewExe.FullName -UseStart

# Add start menu shortcut for current user
Install-ChocolateyShortcut `
  -ShortcutFilePath "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\WinSetView.lnk" `
  -TargetPath $winSetViewExe.FullName `
  -WorkingDirectory $winSetViewExe.FullName

# Cleanup archive
if (Test-Path $zipFile.FullName) {
  Remove-Item $zipFile.FullName -Force
}
