
param (
  [Parameter(Mandatory = $true)][string]$packagePath
)

$ErrorActionPreference = 'Stop'

Import-Module Chocolatey-AU

function Get-Child-Process {
  param ([Parameter(Mandatory = $true)][int]$Id)
  return Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $Id } | ForEach-Object { return Get-Process -Id $_.ProcessId }
}

function Stop-Process-Tree {
  param ([Parameter(Mandatory = $true)][int]$Id)
  Get-Child-Process -Id $Id | ForEach-Object { Stop-Process-Tree $_.Id }
  Stop-Process -Id $Id -ErrorAction SilentlyContinue
}

$currentPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$testPath = Join-Path $currentPath "test"

New-Item $testPath -ItemType "directory" | Out-Null
try {
  Copy-Item -Path $packagePath -Destination $testPath
  Set-Location $testPath
  Test-Package -Install

  Write-Host "Testing winsetview-gui command..."
  try {
    $process = Start-Process -FilePath "winsetview-gui" -PassThru
    Start-Sleep -Seconds 2
    $winSetViewProcess = Get-Child-Process $process.Id | Select-Object -First 1
    if ($winSetViewProcess -and -not $winSetViewProcess.HasExited -and $winSetViewProcess.Name -eq "WinSetView") {
      Write-Host "WinSetView GUI started successfully"
    } else {
      throw "WinSetView GUI failed to start"
    }
  } finally {
    Stop-Process-Tree $process.Id
  }

  Write-Host "Testing winsetview command..."
  try {
    $process = Start-Process -FilePath "winsetview" -PassThru
    Start-Sleep -Seconds 2
    $winSetViewScriptProcess = Get-Child-Process $process.Id | Where-Object { $_.Name.Contains("powershell") } | Select-Object -First 1
    if ($winSetViewScriptProcess) {
      Write-Host "WinSetView powershell script ran successfully"
    } else {
      throw "WinSetView powershell script failed to run"
    }
  } finally {
    Stop-Process-Tree $process.Id
  }

} catch {
  Write-Warning "Encountered error during tests. Cleaning up..."
  throw
} finally {
  try {
    Test-Package -Uninstall
  } catch {
    Write-Error "WinSetView could not be uninstalled during test."
    throw
  } finally {
    Set-Location $currentPath
    Remove-Item $testPath -Recurse -Force
  }
}
