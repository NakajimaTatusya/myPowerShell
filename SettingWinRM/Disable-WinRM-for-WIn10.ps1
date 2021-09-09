# for Windows10 Client 

[CmdletBinding()]
param (
    [string]$currentDir
)

$now = Get-Date
$logFile = "{0}_{1}.log" -f "DisableWinRM", $now.ToString("yyyy-MM-dd")
$stdoutPath = Join-Path $currentDir $logFile
# 成功、警告、エラーストリームをファイルに送信
&{
Write-Output ("{0} WinRMの設定を無効にする処理を開始します。" -f $now.ToString("yyyy/MM/dd HH:mm:ss.fff"))
Disable-PSRemoting -Force

Write-Output "WinRMのポートをふさぎます。"
Get-NetFirewallRule -Name WINRM-HTTP-In-TCP | Set-NetFirewallRule -Enabled false -Profile Any -PassThru

Write-Output "WinRMのサービス設定を無効にします。"
winrm set winrm/config/service/auth '@{Basic="false"}'
winrm set winrm/config/service '@{AllowUnencrypted="false"}'
winrm get winrm/config
} 3>&1 2>&1 >> $stdoutPath
