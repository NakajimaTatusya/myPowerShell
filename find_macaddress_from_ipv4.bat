@echo off

echo ############################################################
echo ### Finding MAC address from IP address ver.202107060935 ###
echo ### Author: Ricoh Japan YAMANASHI Soluetion.             ###
echo ############################################################

REM このバッチはShift-Jisで保存してください。
REM Pingが到達したもののみを収集
REM Usage: find_macaddress_from_ipv4.ps1 -Network 10.22.129 -IPStart 100 -IPEnd 120 -pingStatus0
REM Pingが到達しなかったものも出力
REM Usage: find_macaddress_from_ipv4.ps1 -Network 10.22.129 -IPStart 100 -IPEnd 120
REM debug 出力を有効にする
REM Usage: find_macaddress_from_ipv4.ps1 -Network 10.22.129 -IPStart 100 -IPEnd 120 -pingStatus0 -Verbose
REM Usage: find_macaddress_from_ipv4.ps1 -Network 10.22.129 -IPStart 100 -IPEnd 120 -Verbose

REM 引数「-Verbose」を追加するとデバッグ出力が行われる

REM カレントディレクトリをバッチ実行ディレクトリに変更する
cd /d %~dp0

REM 引数を省略すると、10.22.129.1 ～ 10.22.129.255 まで検索する。
REM powershell -NoProfile -ExecutionPolicy Unrestricted .\find_macaddress_from_ipv4.ps1
REM powershell -NoProfile -ExecutionPolicy Unrestricted .\find_macaddress_from_ipv4.ps1 -Verbose
REM powershell -NoProfile -ExecutionPolicy Unrestricted .\find_macaddress_from_ipv4.ps1 -PingStatusErrorOutput
REM powershell -NoProfile -ExecutionPolicy Unrestricted .\find_macaddress_from_ipv4.ps1 -PingStatusErrorOutput -Verbose

REM Pingの成功したもののみ出力
powershell -NoProfile -ExecutionPolicy Unrestricted .\find_macaddress_from_ipv4.ps1 -Network 10.22.129 -IPStart 100 -IPEnd 120
REM powershell -NoProfile -ExecutionPolicy Unrestricted .\find_macaddress_from_ipv4.ps1 -Network 10.22.129 -IPStart 100 -IPEnd 120 -Verbose

REM Pingの失敗したものも出力
REM powershell -NoProfile -ExecutionPolicy Unrestricted .\find_macaddress_from_ipv4.ps1 -Network 10.22.129 -IPStart 100 -IPEnd 120 -PingStatusErrorOutput
REM powershell -NoProfile -ExecutionPolicy Unrestricted .\find_macaddress_from_ipv4.ps1 -Network 10.22.129 -IPStart 100 -IPEnd 120 -PingStatusErrorOutput -Verbose

REM pause

exit 0
