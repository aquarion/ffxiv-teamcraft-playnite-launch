# Setup - these are global across all scripts for the game
New-Variable -Name "appexe" -Visibility Public -Value ($env:LocalAppData + "\ffxiv-teamcraft\FFXIV Teamcraft.exe")
New-Variable -Name "appname" -Visibility Public -Value "FFXIV Teamcraft"
