
New-Variable -Name "totpServerScript" -Visibility Public -Value (Join-Path $PSScriptRoot "..\auther\totp_server.py")

if (!([System.IO.File]::Exists($totpServerScript))) {
    $PlayniteApi.Dialogs.ShowErrorMessage("TOTP server script not found at: " + $totpServerScript, "Error")
    exit 1
}
Start-Process -FilePath $totpServerScript -WindowStyle Minimized -ArgumentList "--quiet --timeout 60 --interval 1 --quit-after-send"
