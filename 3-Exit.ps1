if(!$companionName){
     New-Variable -Name "companionName" -Visibility Public -Value "FFXIV Teamcraft"
}

# Now stop Teamcraft if it is here
if ($app = Get-Process -Name $companionName -EA 0)
{
    $app = Get-Process -Name $companionName -EA 0
    $app.Kill()
}