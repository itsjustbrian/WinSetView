Import-Module Chocolatey-AU

$version  = "3.0.0"

function global:au_SearchReplace {
  @{}
}

# this actually just gets the specific version, not the latest release
function global:au_GetLatest {
  @{
    Version = $version
    PackageName = "winsetview"
  }
}

update -ChecksumFor none
