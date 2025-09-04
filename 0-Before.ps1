# Setup - these are global across all scripts for the game
New-Variable -Name "appexe" -Visibility Public -Value ($env:LocalAppData + "\ffxiv-teamcraft\FFXIV Teamcraft.exe")
New-Variable -Name "appname" -Visibility Public -Value "FFXIV Teamcraft"
New-Variable -Name "gameExecutable" -Visibility Public -Value "FINAL FANTASY XIV"

if (![System.IO.File]::Exists($appexe)){
  $PlayniteApi.Dialogs.ShowErrorMessage(("Failed to find Teamcraft at " + $env:LocalAppData + "\ffxiv-teamcraft\FFXIV Teamcraft.exe"), "FFXIV Teamcraft Launcher")
  exit 5
}