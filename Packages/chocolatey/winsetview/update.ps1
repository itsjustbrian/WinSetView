
param (
  [Parameter(Mandatory=$true)][string]$version,
  [Parameter(Mandatory=$true)][string]$rootPath
)

$ErrorActionPreference = 'Stop'

function UpdateRawXMLProperty {
  param (
    [Parameter(Mandatory=$true)][string]$xmlContent,
    [Parameter(Mandatory=$true)][string]$property,
    [Parameter(Mandatory=$true)][string]$value
  )

  $xmlContent = $xmlContent -replace "(\s*)(\<$property\>)[\S\s]*(\</$property\>)", "`${1}`${2}$($value)`$3"
  Write-Output $xmlContent
}

$currentPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Get nuspec content
$nuspecPath = Join-Path $currentPath "winsetview.nuspec"
[xml]$nuspecContentXML = Get-Content $nuspecPath
$newNuspecContent = Get-Content $nuspecPath -Raw

# Update version
if ($version) {
  $currentVersion = $nuspecContentXml.package.metadata.version
  $newNuspecContent = UpdateRawXMLProperty -xmlContent $newNuspecContent -property "version" -value $version
  Write-Host "Updating nuspec version: $currentVersion -> $version"
}

# Update description
$descriptionPath = Join-Path $currentPath "Description.md"
$descriptionContent = Get-Content $descriptionPath -Raw
$newDescription = ($descriptionContent -split "`n" | Select-Object -Skip 1) -join "`n"
$newDescription = "<![CDATA[$newDescription]]>"
$newNuspecContent = UpdateRawXMLProperty -xmlContent $newNuspecContent -property "description" -value $newDescription
Write-Host "Updating nuspec description from $descriptionPath"

# Update verification
$verificationPath = Join-Path $currentPath "legal\VERIFICATION.txt"
$exePath = Join-Path $rootPath "WinSetView.exe"
$exeHash = (Get-FileHash -Path $exePath -Algorithm SHA256).Hash
$verificationTemplateContent = Get-Content(Join-Path $currentPath "VERIFICATION.template.txt") -Raw
$verificationTemplateContent = $verificationTemplateContent -replace "{{VERSION}}", $version -replace "{{CHECKSUM}}", $exeHash
Write-Host "Updating verification file with version $version and checksum $exeHash"

# Update icon
try {
  $icoPath = Join-Path $rootPath "Src\WinSetView.ico"
  $tempIconsPath = Join-Path $currentPath "tempIcons"
  New-Item -Path $tempIconsPath -ItemType "directory" | Out-Null
  magick $icoPath "$tempIconsPath\icon.png"
  $allIconPngs = Get-ChildItem -Path $tempIconsPath -Include icon-*.png -Recurse
  $largestIcon
  foreach ($iconPng in $allIconPngs) {
    $sizeStr = magick identify -format "%wx%h" $iconPng.FullName
    $width = [int](($sizeStr -split 'x')[0])
    if ($width -gt ($largestIcon.width ?? 0)) {
      $largestIcon = @{
        image = $iconPng;
        width = $width;
        sizeStr = $sizeStr
      }
    }
  }
  $pngIconPath = "$currentPath\icon.png"
  if ($largestIcon) {
    Write-Host "Updating icon $pngIconPath with size $($largestIcon.sizeStr)"
  } else {
    throw "Could not create png icon from $icoPath"
  }
  if (Test-Path $pngIconPath) {
    Remove-Item $pngIconPath
  }
  Move-Item $largestIcon.image.FullName $pngIconPath
} finally {
  if (Test-Path $tempIconsPath) {
    Remove-Item $tempIconsPath -Recurse
  }
}

# Write files
Set-Content -Path $nuspecPath -Value $newNuspecContent -NoNewline
Set-Content -Path $verificationPath -Value $verificationTemplateContent
