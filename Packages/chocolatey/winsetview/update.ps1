
param (
  [Parameter(Mandatory=$true)][string]$version,
  [Parameter(Mandatory=$true)][string]$assetUrl
)

Import-Module Chocolatey-AU

function global:au_BeforeUpdate() {
  New-Item -Type Directory tools -ea 0 | Out-Null
  $toolsPath = Resolve-Path tools
  $zipFileName = "WinSetView-{0}.zip" -f $version
  $zipFilePath = Join-Path $toolsPath $zipFileName
  Write-Host "Downloading release zip: $assetUrl"
  Invoke-WebRequest $assetUrl -OutFile $zipFilePath
  Write-Host "Saved release zip: $zipFilePath"
}

function global:au_SearchReplace {
  @{}
}

function global:au_GetLatest {
  @{
    Version = $version
    PackageName = "winsetview"
  }
}

update -ChecksumFor none
