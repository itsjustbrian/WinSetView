$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$zipFile = Get-ChildItem -Path $toolsDir -Filter "WinSetView*.zip" | Select-Object -First 1
if (-Not $zipFile) {
  throw ("No WinSetView zip file found in directory {0}" -f $toolsDir)
}

Get-ChocolateyUnzip -FileFullPath $zipFile.FullName -Destination $toolsDir

$winSetViewExeFile = Get-ChildItem -Path $toolsDir -Filter "WinSetView.exe" -Recurse | Select-Object -First 1
$allExeFiles = Get-ChildItem -Path $toolsDir -Include *.exe -Recurse

foreach ($file in $allExeFiles) {
  if ($file.Name -eq $winSetViewExeFile.Name) {
    New-Item "$file.gui" -ItemType file -Force | Out-Null
  } else {
    New-Item "$file.ignore" -ItemType file -Force | Out-Null
  }
}

if (Test-Path $zipFile.FullName) {
  Remove-Item $zipFile.FullName -Force
}
