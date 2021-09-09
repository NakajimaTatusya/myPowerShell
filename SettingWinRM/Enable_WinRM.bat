@echo off

echo ############################################################
echo ### Setting for WinRM.                       ver.20210907###
echo ### Author: Ricoh Japan YAMANASHI Soluetion.             ###
echo ############################################################

cd /d %~dp0
set CURRENTDIR=%~dp0

powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned"
powershell -Command "Get-ExecutionPolicy -List"

powershell -NoProfile -Command "&{Start-Process powershell -ArgumentList '-noprofile -file %CURRENTDIR%\Enable-WinRM-for-WIn10.ps1 -currentDir %CURRENTDIR%' -Verb runas}"

winrm get winrm/config

pause
exit 0
