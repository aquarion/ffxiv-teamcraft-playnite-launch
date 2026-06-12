
## This is what should go into Playnite's "Script" field when creating a new "Custom Script" task.

## Execute Before:
if ($null -eq $codePath) {
    New-Variable -Name codePath -Visibility Public -Value (Join-Path $env:userprofile "code\aquarion\ffxiv-teamcraft-playnite-launch\teamcraft-launcher")
} else {
    $codePath = (Join-Path $env:userprofile "code\aquarion\ffxiv-teamcraft-playnite-launch\teamcraft-launcher")
}

if ($null -eq "beforeScript") {
    New-Variable -Name "beforeScript" -Visibility Public -Value (Join-Path $codePath "0-Before.ps1")
} else {
    $beforeScript = (Join-Path $codePath "0-Before.ps1")
}

## Here's where auther would go if you're using it.

#----

## Execute after a game is started:
if ($null -eq "startScript") {
    New-Variable -Name "startScript" -Visibility Public -Value (Join-Path $codePath "1-Start.ps1")
} else {
    $startScript = (Join-Path $codePath "1-Start.ps1")
}

. $startScript

#----

## Execute after a game is exited:
if ($null -eq "exitScript") {
    New-Variable -Name "exitScript" -Visibility Public -Value (Join-Path $codePath "2-Exit.ps1")
} else {
    $exitScript = (Join-Path $codePath "2-Exit.ps1")
}

. $exitScript
