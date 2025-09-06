# Setup - these are global across all scripts for the game
if(!$companionExe){
New-Variable -Name "companionExe" -Visibility Public -Value ($env:LocalAppData + "\ffxiv-teamcraft\FFXIV Teamcraft.exe")
}

if(!$companionName){
New-Variable -Name "companionName" -Visibility Public -Value "FFXIV Teamcraft"
}

if(!$gameExecutable){
New-Variable -Name "gameExecutable" -Visibility Public -Value "ffxiv_dx11"
}

if (![System.IO.File]::Exists($companionExe)){
  $PlayniteApi.Dialogs.ShowErrorMessage(("Failed to find Teamcraft at " + $companionExe), "FFXIV Teamcraft Launcher")
  exit 5
}