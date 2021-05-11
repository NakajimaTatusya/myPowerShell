# ここから ノートパッドを管理者権限で実行
Start-Process -FilePath "notepad.exe" -ArgumentList "C:\Windows\System32\drivers\etc\hosts" -Verb runas
# ここまで
