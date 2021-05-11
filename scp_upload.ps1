# ここから下は PowerShellスクリプト
$remote_host = "192.168.1.100"
$username = "username"
# アップデート先
$remote_path1 = "/home/user01/upload/csvfile01"
# アップデート先
$remote_path2 = "/home/user01/upload/csvfile02"
# アップデート先
$remote_path3 = "/home/user01/upload/csvfile03"
# SSH認証
$cred = Get-Credential $username

# Posh-SSHモジュールが導入されていない場合、PowerShellに導入する
if (!(Get-Module -ListAvailable -Name Posh-SSH)) {
    Install-Module -Name Posh-SSH -Force
}

# ファイルアップロード実行
cd .\local_folder01\
Get-ChildItem * -Recurse | Select-Object FullName | ForEach-Object -Process {
	Set-SCPFile -LocalFile $_.FullName -RemotePath $remote_path1 -ComputerName $remote_host -Credential $cred
}
Write-Host "hogehogeファイルアップロード完了"
cd ..\local_folder02\
Get-ChildItem * -Recurse | Select-Object FullName | ForEach-Object -Process {
	Set-SCPFile -LocalFile $_.FullName -RemotePath $remote_path2 -ComputerName $remote_host -Credential $cred
}
Write-Host "hogehogeファイルアップロード完了"
cd ..\local_folder03\
Get-ChildItem * -Recurse | Select-Object FullName | ForEach-Object -Process {
	Set-SCPFile -LocalFile $_.FullName -RemotePath $remote_path3 -ComputerName $remote_host -Credential $cred
}
Write-Host "hogehogeファイルアップロード完了"

exit
