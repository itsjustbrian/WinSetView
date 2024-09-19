
param (
  [Parameter(Mandatory=$true)][string]$apiKey
)

$ErrorActionPreference = 'Stop'

$currentPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$nuspecPath = Join-Path $currentPath "winsetview.nuspec"
[xml]$nuspecXml = Get-Content $nuspecPath

$version = $nuspecXml.package.metadata.version

$chocoUrl = "https://chocolatey.org/packages/winsetview/$version"
try {
    request $chocoUrl | out-null
    Write-Host "Version $verion already exists in the Chocolatey community feed. Exiting..."
    return
} catch { }

New-Item -Type Directory tools -ea 0 | Out-Null
$toolsPath = Resolve-Path tools
$zipFileName = "WinSetView-$version.zip"
$zipFilePath = Join-Path $toolsPath $zipFileName

$assetUrl = "https://github.com/LesFerch/WinSetView/archive/refs/tags/$version.zip"
Write-Host "Downloading release: $assetUrl"
Invoke-WebRequest $assetUrl -OutFile $zipFilePath
Write-Host "Saved release: $zipFilePath"

choco pack $nuspecPath --limit-output
$package = Get-ChildItem -Filter *.nupkg | Select-Object -First 1
if (!$package) {
  throw 'There is no nupkg file in the directory'
}
Write-Host "Created nupkg: $package"

$pushUrl = 'https://push.chocolatey.org'
# choco push $package.Name --api-key $apiKey --source $pushUrl
