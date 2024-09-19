
$ErrorActionPreference = 'Stop'

$currentPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$nuspecPath = Join-Path $currentPath "winsetview.nuspec"
[xml]$nuspecXml = Get-Content $nuspecPath

$version = $nuspecXml.package.metadata.version

$chocoUrl = "https://chocolatey.org/packages/winsetview/$version"
try {
    request $chocoUrl | out-null
    # TODO: Maybe error here?
    Write-Host "Version $verion already exists in the Chocolatey community feed ($chocoUrl). Exiting..."
    return
} catch { }

$zipFileName = "WinSetView-$version.zip"
$zipFilePath = Join-Path $currentPath "tools" $zipFileName

$assetUrl = "https://github.com/LesFerch/WinSetView/archive/refs/tags/$version.zip"
Write-Host "Downloading release: $assetUrl"
Invoke-WebRequest $assetUrl -OutFile $zipFilePath
Write-Host "Saved release: $zipFilePath"

choco pack $nuspecPath --out $currentPath --limit-output | Out-Host
$package = Get-ChildItem -Path $currentPath -Filter *.nupkg | Select-Object -First 1
if (!$package) {
  # TODO maybe more info here?
  throw 'No nupkg file was found after build'
}

Write-Output $package.FullName
