# $files = get-childitem $toolsDir -include *.exe -recurse

# foreach ($file in $files) {
#     Write-Host $file
#     if ($file.Name -eq "WinSetView.exe") {
#         Write-Host "hello"
#     }
# }

$zipFile = Get-ChildItem -Path $toolsDir -Filter "WinSetView*.zips" | Select-Object -First 1
if (-Not $zipFile) {
  Exit 1
}
Write-Host $zipFile