# UACを無効化
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0
$confirm = Read-Host "再起動します。[y/N]"
if ($confirm -eq "y") {
    Restart-Computer -Force
}
