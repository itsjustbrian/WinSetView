$files = get-childitem $toolsDir -include *.exe -recurse

foreach ($file in $files) {
    Write-Host $file
    if ($file.Name -eq "WinSetView.exe") {
        Write-Host "hello"
    }
}