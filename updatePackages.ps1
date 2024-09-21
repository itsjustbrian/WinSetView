param (
  [Parameter(Mandatory=$true)][string]$version
)

./Packages/chocolatey/winsetview/update.ps1 -version $version -rootPath ./
