REM 自分のラップトップがWiFiに接続されていたら、モバイルホットスポットを起動する
@echo off
echo モバイルホットスポットを起動しています。
powershell -NoProfile -ExecutionPolicy Unrestricted .\EnableTetheringWhenConnectToCompanyNetwork.ps1
pause
exit
