# myPowerShell

雑多なPowerShellスクリプト集、とにかく作ったものをまとめる

## 一覧

| Script | Description |
| :---   | :--- |
| confirm_open_port.ps1 | TCP接続を試す |
| dsk_scale.ps1 | Windows10 拡大縮小とレイアウト。テキスト、アプリ、その他の項目のサイズを変更する |
| EnableTetheringWhenConnectToCompanyNetwork.bat | 自分のラップトップがWiFiに接続されていたら、モバイルホットスポットを起動する |
| EnableTetheringWhenConnectToCompanyNetwork.ps1 | 自分のラップトップがWiFiに接続されていたら、モバイルホットスポットを起動する |
| get_wifi_ssid.ps1 | WiFiアクセスポイントのSSIDを一覧表示する |
| RunAsAdministrator.ps1 | 指定されたスクリプトを管理者権限で実行する |
| TestRunAsAdministrator.ps1 | ノートパッドを管理者権限で実行し、hostsファイルを編集する |
| scp_upload.ps1 | Posh-SSH を使用してファイルをアップロードする |
| tail_like_command.ps1 | tail -f のような挙動をするコマンドレット |
| test_conn_sql_server.ps1 | SQL Server へ接続するテスト用 |
| test.txt | tail_like_command.ps1の動作確認用 |
| ssh_bash_command.bat | SSH接続してコマンドを実行して終了するバッチ(Windows10 1803以降) |
| output_eventlog.ps1 | Windows Application Event log をCSV出力 |
| find-install-app-path.ps1 | アプリケーションがインストールされた場所を取得する |
| Get-RemoteOfficeVersion.ps1 | オリジナル。get-officeinstallpath.ps1の元ネタ。前半の処理がどこへも戻されていないので多分そののままでは使えない。 |
| get-officeinstallpath.ps1 | Get-RemoteOfficeVersion.ps1そのままだと使えないので、てを加えて不要なものをそぎ落とした。 |
| get-folderfile-information-config.ps1 | 対象のパスを指定する。Windowsのスペシャルフォルダはコメント(#)記号を消すと有効化される。 |
| get-folderfile-information.ps1 | get-folderfile-information-config.ps1にしていたされたパスのフォルダとファイルの情報を収集してCSV出力する。 |
