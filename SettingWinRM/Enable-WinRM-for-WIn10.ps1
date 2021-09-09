# for Windows10 Client 

[CmdletBinding()]
param (
    [string]$currentDir
)

$now = Get-Date
$logFile = "{0}_{1}.log" -f "EnableWinRM", $now.ToString("yyyy-MM-dd")
$stdoutPath = Join-Path $currentDir $logFile
# 成功、警告、エラーストリームをファイルに送信
&{
Write-Output ("{0} WinRMの設定を有効にする処理を開始します。" -f $now.ToString("yyyy/MM/dd HH:mm:ss.fff"))
Enable-PSRemoting -SkipNetworkProfileCheck

Write-Output "WinRMのポートを解放します。"
Get-NetFirewallRule -Name WINRM-HTTP-In-TCP | Set-NetFirewallRule -Enabled true -Profile Any -PassThru

Write-Output "WinRMのサービス設定を有効にします。"
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm get winrm/config
} 3>&1 2>&1 >> $stdoutPath
