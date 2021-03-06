# myPowerShell

PowerShellスクリプト集

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
| disableUAC.ps1 | UACを無効にする。再起動が必要。 |
| 管理者権限実行powershell埋め込み型.bat | 管理者権限でPowerShellを実行。 |
| Setting-WinRM-for-WIn10.ps1 | Windows10クライアントへWinRM設定を行う。 |
| find_macaddress_from_ipv4.ps1 | IPv4/24範囲にPingを送信ARPからMACアドレスを収集してCSV出力 |
| find_macaddress_from_ipv4.bat | find_macaddress_from_ipv4.ps1を起動するバッチ |
| async_ping.ps1 | PINGを非同期で行う。処理速度が早い。 |
| data_migration\Backup_for_data_migration.ps1 | データ移行のためのバックアップ実行 |
| data_migration\Backup_for_data_migration.bat | バックアップPowershellスクリプトを実行する |
| data_migration\backup_conf\Backup_for_data_migration.conf | データ移行個別フォルダ設定 |
| data_migration\backup_conf\Backup_for_data_migration_specialfolder.ps1 | データ移行スペシャルフォルダ設定 |
| data_migration\Restore_for_data_migration.ps1 | ROBOCOPYでバックアップをとったデータを別のPCレストアする |
| data_migration\Restore_for_data_migration.bat | レストアPowershellスクリプトを実行する |
| data_migration\library\AppCommon.psm1 | ROBOCOPYを使用したバックアップレストア用のライブラリ |
| ChromeBrowserUserData\Moving_favorities_backup.bat | バックアップ実行 |
| ChromeBrowserUserData\Moving_favorities_newChrome.ps1 | クロムブラウザのUser Data Defaultをバックアップ、リストアする |
| ChromeBrowserUserData\Moving_favorities_restore.bat | リストア実行 |
| windows_credential_manager.bat | windows 資格情報の追加、編集、削除、エクスポート/インポート GUIを呼び出すバッチコマンド |
| \SettingWinRM\Enable_WinRM.bat | WinRM有効バッチ、管理者権限で実行のこと。PowerShellスクリプトファイルの実行許可も行う。 |
| \SettingWinRM\Enable-WinRM-for-WIn10.ps1 | WinRM有効スクリプトファイル |
| \SettingWinRM\Disable_WinRM.bat | WinRM無効バッチ、管理者権限で実行のこと。PowerShellスクリプトファイルの実行不許可にする。 |
| \SettingWinRM\Disable-WinRM-for-WIn10.ps1 | WinRM無効スクリプトファイル |
