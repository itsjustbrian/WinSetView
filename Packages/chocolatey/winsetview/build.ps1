param (
  [Parameter(Mandatory=$true)][string]$rootPath
)

$ErrorActionPreference = 'Stop'

$currentPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Get nuspec content
$nuspecPath = Join-Path $currentPath "winsetview.nuspec"
[xml]$nuspecXml = Get-Content $nuspecPath

$version = $nuspecXml.package.metadata.version
Write-Host "Building verion $version from nuspec $nuspecPath"

# Sanity check that we are deploying a binary that matches verification details
$verificationPath = Join-Path $currentPath "legal/VERIFICATION.txt"
$verificationContent = Get-Content $verificationPath -Raw
$verificationHash = if ($verificationContent -match '\bchecksum: ([a-zA-Z0-9]*)') {
  $matches[1]
}
$exePath = Join-Path $rootPath "WinSetView.exe"
$exeHash = (Get-FileHash -Path $exePath -Algorithm SHA256).Hash
if ($exeHash -eq $verificationHash) {
  Write-Host "WinSetView.exe checksum matches verification checksum: $verificationHash"
} else {
  throw "Verification checksum did not match current exe checksum`nverification checksum: {0}`nexe checksum: {1}" -f $verificationHash, $exeHash
}

# Desired archive path
$zipFileName = "WinSetView-$version.zip"
$zipFilePath = Join-Path $currentPath "tools\$zipFileName"

# Create zip archive of current branch head.
# Git archive must be run from the root of the repo.
Set-Location $rootPath
git archive -o $zipFilePath HEAD
Set-Location $currentPath

# Create nupkg
choco pack $nuspecPath --out $currentPath --limit-output | Out-Host

# Cleanup archive
if (Test-Path $zipFilePath) {
  Remove-Item $zipFilePath -Force
}

# Sanity check that nupkg was created successfully
$package = Get-ChildItem -Path $currentPath -Filter *.nupkg | Select-Object -First 1
if (!$package) {
  throw ('No nupkg file was found after build in {0}' -f $currentPath)
}

Write-Output $package
