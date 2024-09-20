$ErrorActionPreference = 'Stop' # stop on all errors

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$installDir = Join-Path $env:ProgramFiles 'MyApp'
$appDataDir = Join-Path $installDir 'AppData'

# Check if the AppData folder exists, and if so, remove it
if (Test-Path $appDataDir) {
    Remove-Item -Path $appDataDir -Recurse -Force
    Write-Host "Removed AppData directory."
}

# Optionally remove the main installation directory if empty
if (Test-Path $installDir -and (Get-ChildItem $installDir | Measure-Object).Count -eq 0) {
    Remove-Item -Path $installDir -Recurse -Force
    Write-Host "Removed installation directory."
}
