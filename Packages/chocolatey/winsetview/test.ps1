
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

# Create testing folder
$testPath = Join-Path $currentPath "test"
New-Item $testPath -ItemType "directory" | Out-Null
try {
  Copy-Item -Path $packagePath -Destination $testPath
  Set-Location $testPath

  # Install package
  Test-Package -Install

  Write-Host "Testing winsetview command..."
  try {
    $process = Start-Process -FilePath "winsetview" -PassThru
    Start-Sleep -Seconds 2
    # WinSetView process is a child of the shim
    $winSetViewProcess = Get-Child-Process $process.Id | Select-Object -First 1
    # Ensure process exists and is still running
    if ($winSetViewProcess -and -not $winSetViewProcess.HasExited -and $winSetViewProcess.Name -eq "WinSetView") {
      Write-Host "WinSetView started successfully"
    } else {
      throw "WinSetView failed to start"
    }
  } finally {
    Stop-Process-Tree $process.Id
  }

  Write-Host "Testing winsetview-cli command..."
  try {
    $process = Start-Process -FilePath "winsetview-cli" -PassThru
    Start-Sleep -Seconds 2
    # Chocolatey batch shim starts a couple children.
    # The one with 'powershell' in the name is the script itself.
    $winSetViewScriptProcess = Get-Child-Process $process.Id | Where-Object { $_.Name.Contains("powershell") } | Select-Object -First 1
    # Existence is all we test for
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
    # Uninstall package even if an error occured
    Test-Package -Uninstall
  } catch {
    # If running locally, you may need to manually remove/uninstall
    Write-Error "WinSetView could not be uninstalled during test."
    throw
  } finally {
    Set-Location $currentPath
    Remove-Item $testPath -Recurse -Force
  }
}
