param (
  [Parameter(Mandatory=$true)][string]$package,
  [Parameter(Mandatory=$true)][string]$apiKey
)

$ErrorActionPreference = 'Stop'

$pushUrl = 'https://push.chocolatey.org'
choco push $package --api-key $apiKey --source $pushUrl
