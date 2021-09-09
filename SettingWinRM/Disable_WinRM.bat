@echo off

echo ############################################################
echo ### Setting for WinRM.                       ver.20210909###
echo ### Author: Ricoh Japan YAMANASHI Soluetion.             ###
echo ############################################################

cd /d %~dp0
set CURRENTDIR=%~dp0

powershell -NoProfile -Command "&{Start-Process powershell -ArgumentList '-noprofile -file %CURRENTDIR%\Disable-WinRM-for-WIn10.ps1 -currentDir %CURRENTDIR%' -Verb runas}"

powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope LocalMachine"
powershell -Command "Get-ExecutionPolicy -List"

pause
exit 0
