# for Windows10 Client 

[CmdletBinding()]
param (
    [string]$currentDir
)

$now = Get-Date
$logFile = "{0}_{1}.log" -f "DisableWinRM", $now.ToString("yyyy-MM-dd")
$stdoutPath = Join-Path $currentDir $logFile
# �����A�x���A�G���[�X�g���[�����t�@�C���ɑ��M
&{
Write-Output ("{0} WinRM�̐ݒ�𖳌��ɂ��鏈�����J�n���܂��B" -f $now.ToString("yyyy/MM/dd HH:mm:ss.fff"))
Disable-PSRemoting -Force

Write-Output "WinRM�̃|�[�g���ӂ����܂��B"
Get-NetFirewallRule -Name WINRM-HTTP-In-TCP | Set-NetFirewallRule -Enabled false -Profile Any -PassThru

Write-Output "WinRM�̃T�[�r�X�ݒ�𖳌��ɂ��܂��B"
winrm set winrm/config/service/auth '@{Basic="false"}'
winrm set winrm/config/service '@{AllowUnencrypted="false"}'
} 3>&1 2>&1 >> $stdoutPath
