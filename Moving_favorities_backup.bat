@echo off

echo ############################################################
echo ### Back up your Chrome data.                ver.20210729###
echo ### Author: Ricoh Japan YAMANASHI Soluetion.             ###
echo ############################################################

cd /d %~dp0

powershell -NoProfile -ExecutionPolicy Unrestricted .\Moving_favorities_newChrome.ps1 -BACKUP
pause

exit 0
