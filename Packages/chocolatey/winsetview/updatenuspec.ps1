
param (
  [Parameter(Mandatory=$true)][string]$version,
  [Parameter(Mandatory=$true)][string]$readMePath
)

$ErrorActionPreference = 'Stop'

$currentPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$readmeContent = Get-Content $readmePath -Raw

$nuspecPath = Join-Path $currentPath "winsetview.nuspec"
[xml]$nuspecXml = Get-Content $nuspecPath

$nuspecXml.package.metadata.version = $version
$nuspecXml.package.metadata.description = $readmeContent

$nuspecXml.Save($nuspecPath)
