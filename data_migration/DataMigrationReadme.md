# データ移行アプリケーション

## Powershellスクリプト情報

* 開発に使用した PowerShell Version

| Major | Minor | Build | Revision |
| ---: | ---: | ---: | ---: |
| 5 | 1 | 19041 | 1023 |

## モジュール構成と入出力

```CMD
root\
│
├─backup_data_migration
│  └─<hostname>
│      YYYY-MM-DD_robocopy.log    (ロボコピー実行ログ)
│      バックアップデータ
│      
├─data_migration
│  │  Backup_for_data_migration.ps1
│  │  Restore_for_data_migration.ps1
│  │  バックアップ.bat  (バックアップ実行バッチファイル)
│  │  復元.bat  (復元実行バッチファイル)
│  │  
│  ├─backup_conf
│  │      Backup_for_data_migration.conf    (個別設定パスリストファイル)
│  │      Backup_for_data_migration_specialfolder.ps1   (必須バックアップ対象パスリスト)
│  │      
│  ├─data_migration_logs
│  │      BackupForDataMigration_yyyy-mm-dd.log   (バックアップ実行ログ)
│  │      RestoreForDataMigration_yyyy-mm-dd.log   (リストア実行ログ)
│  │      
│  └─restore_conf
│          restore_<hostname>_YYYYMMDD_HHMMSS.conf   (復元用設定ファイル、バックアップ実行時にアプリケーションが自動生成)
│          
├─library
│      AppCommon.psm1   (アプリケーション用共通モジュール)
│      
└─restore_data_migration
│   └─<hostname>
│      YYYY-MM-DD_robocopy.log    (ロボコピー実行ログ)
│      リストア先情報、リストアログファイル   (アプリケーションが生成)
```
