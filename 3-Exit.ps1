if(!$appname){
     New-Variable -Name "appname" -Visibility Public -Value "FFXIV Teamcraft"
}

# Now stop Teamcraft if it is here
if ($app = Get-Process -Name $appname -EA 0)
{
    $app = Get-Process -Name $appname -EA 0
    $app.Kill()
}