$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Find WinSetView archive
$zipFile = Get-ChildItem -Path $toolsDir -Filter "WinSetView*.zip" | Select-Object -First 1
if (-Not $zipFile) {
  throw ("No WinSetView zip file found in directory {0}" -f $toolsDir)
}

# Unzip archive
Get-ChocolateyUnzip -FileFullPath $zipFile.FullName -Destination $toolsDir

# Add shim exclusions and GUI shim configuration
# https://docs.chocolatey.org/en-us/create/create-packages/#how-do-i-exclude-executables-from-getting-shims
$winSetViewExeFile = Get-ChildItem -Path $toolsDir -Filter "WinSetView.exe" -Recurse | Select-Object -First 1
$allExeFiles = Get-ChildItem -Path $toolsDir -Include *.exe -Recurse
foreach ($file in $allExeFiles) {
  if ($file.Name -eq $winSetViewExeFile.Name) {
    New-Item "$file.gui" -ItemType file -Force | Out-Null
  } else {
    New-Item "$file.ignore" -ItemType file -Force | Out-Null
  }
}

# Cleanup archive
if (Test-Path $zipFile.FullName) {
  Remove-Item $zipFile.FullName -Force
}
