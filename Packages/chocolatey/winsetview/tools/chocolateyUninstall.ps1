$ErrorActionPreference = 'Stop';

# Remove shim and batch file
Uninstall-BinFile -Name "winsetview"
Uninstall-BinFile -Name "winsetview-cli"

# Remove shortcut
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\WinSetView.lnk"
if (Test-Path $shortcutPath) {
  Remove-Item $shortcutPath -Force
}
