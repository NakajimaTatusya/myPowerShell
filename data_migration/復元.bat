@echo off

echo ############################################################
echo ### Restore for data migration               ver.20210806###
echo ### Author: Ricoh Japan YAMANASHI Soluetion.             ###
echo ############################################################

cd /d %~dp0

powershell -NoProfile -ExecutionPolicy Unrestricted .\Restore_for_data_migration.ps1
REM powershell -NoProfile -ExecutionPolicy Unrestricted .\Restore_for_data_migration.ps1 -Verbose

pause
exit 0
