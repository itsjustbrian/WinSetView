param (
  [Parameter(Mandatory=$true)][string]$package,
  [Parameter(Mandatory=$true)][string]$apiKey
)

$ErrorActionPreference = 'Stop'

# Sanity check that we aren't trying to publish a version
# that is already published.
$chocoPackagesUrl = "https://chocolatey.org/packages/winsetview/$version"
try {
  Invoke-WebRequest $chocoPackagesUrl | out-null
  throw ("Version {0} already exists in the Chocolatey community feed ({1})" -f $verion, $chocoPackagesUrl)
} catch [System.Net.Http.HttpRequestException] { 
  # Version does not exist in community feed. Continue.
} 

$pushUrl = 'https://push.chocolatey.org'
choco push $package --api-key $apiKey --source $pushUrl
