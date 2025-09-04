if (![System.IO.File]::Exists($appexe)){
  $PlayniteApi.Dialogs.ShowErrorMessage(("Failed to find Teamcraft at \r\n " + $env:LocalAppData + "\ffxiv-teamcraft\FFXIV Teamcraft.exe"), "FFXIV Teamcraft Launcher")
  exit 5
}

# Wait for the launcher to launch (-EA 0 means don't throw an exception when this fails)
$pleaseWait = 0 # How many times we've looped though waiting
$launcherLoopWaitTime = 3 # How long to wait between checks
$pleaseWaitPatienceSeconds = 120 # How long to wait before giving up (in seconds)

$pleaseWaitPatience = $pleaseWaitPatienceSeconds/$launcherLoopWaitTime # How many times to loop before giving up (in loops)


while (!($launcher = Get-Process $gameExecutable -EA 0) -and ($pleaseWait -lt $pleaseWaitPatience ) ){
      Start-Sleep -Seconds $launcherLoopWaitTime
      $pleaseWait++
}

# If we've waited too long, give up
if ($pleaseWait -ge $pleaseWaitPatience){
   $PlayniteApi.Dialogs.ShowErrorMessage("Got bored waiting for launcher", "FFXIV Teamcraft Launcher")
   Exit 200
}

# ... then give the game some time to get its act together
Start-Sleep -Seconds 10

# Now launch Teamcraft if it isn't launched
if (!(Get-Process -Name $appname -EA 0))
{
    Start-Process -FilePath $appexe
}