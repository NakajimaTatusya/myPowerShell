# Windows Application Event log をCSV出力
Get-EventLog -LogName Application | Where-Object Source -Match postgres | Export-Csv -NoTypeInformation c:\temp\win_event_log.csv -Encoding UTF8
