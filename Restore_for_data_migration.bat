@echo off

echo ############################################################
echo ### Restore for data migration               ver.20210727###
echo ### Author: Ricoh Japan YAMANASHI Soluetion.             ###
echo ############################################################

cd /d %~dp0

powershell -NoProfile -ExecutionPolicy Unrestricted .\Restore_for_data_migration.ps1^
 -parentdir "c:\tmp"
pause
exit 0
