@(echo '> NUL
echo off)
NET SESSION > NUL 2>&1
IF %ERRORLEVEL% neq 0 goto RESTART
setlocal enableextensions
set "THIS_PATH=%~f0"
set "PARAM_1=%~1"
PowerShell.exe -Command "iex -Command ((gc \"%THIS_PATH:`=``%\") -join \"`n\")"
exit /b %errorlevel%
:RESTART
powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process %~f0 -Verb runas"
exit
') | sv -Name TempVar
# ここから下は PowerShellスクリプト
# Windows Client で実行
#WinRM Enabled
Enable-PSRemoting
# Setting Windows Firewall
Get-NetFirewallRule -Name WINRM-HTTP-In-TCP | Set-NetFirewallRule -Enabled true -Profile Any -PassThru
# WinRM Service Configration
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

exit
