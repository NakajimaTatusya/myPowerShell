@echo off

echo ############################################################
echo ### Backup for Data migration.               ver.20210727###
echo ### Author: Ricoh Japan YAMANASHI Soluetion.             ###
echo ############################################################

cd /d %~dp0

powershell -NoProfile -ExecutionPolicy Unrestricted .\Backup_for_data_migration.ps1^
 -parentdir "c:\tmp"^
 -confpath ".\backup_conf\Backup_for_data_migration.conf"
pause

exit 0
