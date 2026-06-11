# Aquarion's Random FFXIV Scripts

## FFXIV-TeamCraft Powershell Launch Scripts: ./teamcraft-launcher

This is a set of Powershell scripts to get [playnite](https://playnite.link/) to launch [FFXIV Teamcraft](https://ffxivteamcraft.com/) when FFXIV starts, and close it once it exits.

### Installation

Launch these PS files into the Action Scripts boxes in Playnite, like this:

![Action Scripts Window](images/docs-scripts-window.png)

```powershell

New-Variable -Name codePath -Visibility Public -Value (Join-Path $env:userprofile "code\aquarion\ffxiv-teamcraft-playnite-launch\teamcraft-launcher")
New-Variable -Name "beforeScript" -Visibility Public -Value (Join-Path $codePath "0-Before.ps1")
New-Variable -Name "startScript" -Visibility Public -Value (Join-Path $codePath "1-Start.ps1")
New-Variable -Name "exitScript" -Visibility Public -Value (Join-Path $codePath "2-Exit.ps1")

. $beforeScript
```

```powershell
. $startScript
```

```powershell
. $exitScript
```
