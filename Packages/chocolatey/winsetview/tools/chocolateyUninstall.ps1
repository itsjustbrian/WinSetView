$ErrorActionPreference = 'Stop';

# Remove batch file and shim
Uninstall-BinFile -Name "winsetview"
Uninstall-BinFile -Name "winsetview-gui"

# Remove shortcut
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\WinSetView.lnk"
if (Test-Path $shortcutPath) {
  Remove-Item $shortcutPath -Force
}
