$cred = Get-Credential -UserName Administrator -Message "Administratorのパスワード"
$hostname = "192.168.1.202"
$session = New-PSSession –ComputerName $hostname -Credential $cred
Copy-Item -Path 'C:\Users\hogehoge\Documents\debug.log' -Destination 'C:\tmp\' -ToSession $session
$session | Remove-PSSession
