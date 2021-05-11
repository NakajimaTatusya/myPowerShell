
# PowerShell tcp connect test
# 対象アドレスのポートが解放されているか確認する。

Write-Host "対象アドレスのポートが解放されているか確認するスクリプト"
$address = "localhost"
$portNo = 8080
$tc = New-Object System.Net.Sockets.TcpClient
$tc.Connect($address, $portNo)
$tc.connected
