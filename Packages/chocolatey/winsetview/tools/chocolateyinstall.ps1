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

# Make WinSetView.ps1 available on PATH as winsetview
$winSetViewScript = Get-ChildItem -Path "$toolsDir\WinSetView.ps1"
Install-ChocolateyPowershellCommand -PackageName "winsetview" -PSFileFullPath $winSetViewScript

# Make WinSetView.exe available on PATH as winsetview-gui
$winSetViewGui = Get-ChildItem -Path "$toolsDir\WinSetView.exe"
Install-BinFile -Name "winsetview-gui" -Path $winSetViewGui.FullName -UseStart

# Add start menu shortcut
Install-ChocolateyShortcut `
  -ShortcutFilePath "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\WinSetView.lnk" `
  -TargetPath $winSetViewGui.FullName `
  -WorkingDirectory $winSetViewGui.FullName

# Cleanup archive
if (Test-Path $zipFile.FullName) {
  Remove-Item $zipFile.FullName -Force
}
