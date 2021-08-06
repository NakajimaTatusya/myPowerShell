@echo off

echo ############################################################
echo ### Backup for Data migration.               ver.20210806###
echo ### Author: Ricoh Japan YAMANASHI Soluetion.             ###
echo ############################################################

cd /d %~dp0

powershell -NoProfile -ExecutionPolicy Unrestricted .\Backup_for_data_migration.ps1
REM powershell -NoProfile -ExecutionPolicy Unrestricted .\Backup_for_data_migration.ps1 -Verbose

pause
exit 0
