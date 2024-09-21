param (
  [Parameter(Mandatory=$true)][string]$exePath
)

$ErrorActionPreference = 'Stop'

$currentPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$nuspecPath = Join-Path $currentPath "winsetview.nuspec"
[xml]$nuspecXml = Get-Content $nuspecPath

$version = $nuspecXml.package.metadata.version
Write-Host "Building verion $version from nuspec $nuspecPath"

$verificationPath = Join-Path $currentPath "legal/VERIFICATION.txt"
$verificationContent = Get-Content $verificationPath -Raw
$verificationHash = if ($verificationContent -match '\bchecksum: ([a-zA-Z0-9]*)') {
  $matches[1]
}
$exeHash = (Get-FileHash -Path $exePath -Algorithm SHA256).Hash
if ($exeHash -eq $verificationHash) {
  Write-Host "WinSetView.exe checksum matches verification checksum: $verificationHash"
} else {
  throw "Verification checksum did not match current exe checksum`nverification checksum: {0}`nexe checksum: {1}" -f $verificationHash, $exeHash
}

$zipFileName = "WinSetView-$version.zip"
$zipFilePath = Join-Path $currentPath "tools" $zipFileName

git archive -o $zipFilePath HEAD
choco pack $nuspecPath --out $currentPath --limit-output | Out-Host
if (Test-Path $zipFilePath) {
  Remove-Item $zipFilePath -Force
}

$package = Get-ChildItem -Path $currentPath -Filter *.nupkg | Select-Object -First 1
if (!$package) {
  throw ('No nupkg file was found after build in {0}' -f $currentPath)
}

Write-Output $package
