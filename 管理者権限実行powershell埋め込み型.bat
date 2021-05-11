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
Start-Process -FilePath notepad.exe -ArgumentList "C:\Windows\System32\drivers\etc\hosts" -Wait
exit
