#スクリプトパス取得
#$ScriptPath = $MyInvocation.MyCommand.Path

#「Microsoft Edge」タスクバーからピン留めを外す
$AppName = "Microsoft Edge"
$wshell = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $AppName}
$wshell.Verbs() | Where-Object {$_.Name -like "*タスク バーからピン留めを外す*"} | ForEach-Object{$_.DoIt()}

#「Microsoft Store」タスクバーからピン留めを外す
$AppName = "Microsoft Store"
$wshell = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $AppName}
$wshell.Verbs() | Where-Object {$_.Name -like "*タスク バーからピン留めを外す*"} | ForEach-Object{$_.DoIt()}

#「メール」タスクバーからピン留めを外す
$AppName = "メール"
$wshell = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $AppName}
$wshell.Verbs() | Where-Object {$_.Name -like "*タスク バーからピン留めを外す*"} | ForEach-Object{$_.DoIt()}

$AppName = "Internet Explorer"
$wshell = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $AppName}
$wshell.Verbs() | Where-Object {$_.Name -like "*タスク バーからピン留めを外す*"} | ForEach-Object{$_.DoIt()}


# アプリケーション登録名確認
$wshell = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Select-Object Name