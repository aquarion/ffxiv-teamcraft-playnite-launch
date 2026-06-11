#### Add this to Playnite's "Before Launch" script for the game, and it will start the TOTP server before launching the game.
# The server will automatically send the OTP to XIVLauncher, which can then pass it to the game.
# Make sure to set the "companionExe" variable to the path of your FFXIV Teamcraft executable if it's not in the default location.

# Setup - these are global across all scripts for the game

### Teamcraft variables - these can be overridden by setting them in Playnite's "Before Launch" script, or by setting them as environment variables before launching Playnite
if(!$companionExe){
New-Variable -Name "companionExe" -Visibility Public -Value ($env:LocalAppData + "\ffxiv-teamcraft\FFXIV Teamcraft.exe")
}

if(!$companionName){
New-Variable -Name "companionName" -Visibility Public -Value "FFXIV Teamcraft"
}

### Game variables - these can be overridden by setting them in Playnite's "Before Launch" script, or by setting them as environment variables before launching Playnite
if(!$gameExecutable){
New-Variable -Name "gameExecutable" -Visibility Public -Value "ffxiv_dx11"
}

if (![System.IO.File]::Exists($companionExe)){
  $PlayniteApi.Dialogs.ShowErrorMessage(("Failed to find Teamcraft at " + $companionExe), "FFXIV Teamcraft Launcher")
  exit 5
}
