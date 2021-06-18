#powercfg /GETACTIVESCHEME
#powercfg /ALIASESH
#powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
#powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS LIDACTION 1

# 管理者権限が必要
# 現在の電源管理スキーマをバックアップ
#powercfg /export C:\temp\power_management_backup SCHEME_CURRENT

# AC電源
# コンピューターをスリープ状態にするを適用しない
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0
# DC電源
# コンピューターをスリープ状態にするを適用しない
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0


# GUID を取り出す
$test `
| Select-String -Pattern '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}' -AllMatches `
| Select-Object -ExpandProperty Matches `
| Select-Object -ExpandProperty Value

