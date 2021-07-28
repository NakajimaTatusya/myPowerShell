@echo off

echo ############################################################
echo ### Data migration for win10 client.    ver.20210727     ###
echo ### Author: Ricoh Japan YAMANASHI Soluetion.             ###
echo ############################################################

cd /d %~dp0

REM                                                                                            ↓適宜変更         ↓適宜変更
powershell -NoProfile -ExecutionPolicy Unrestricted .\Backup_for_data_migration.ps1 -parentdir c:\tmp -confpath .\Backup_for_data_migration.conf
pause
exit 0
