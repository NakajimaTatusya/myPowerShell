# Windows10 拡大縮小とレイアウト。テキスト、アプリ、その他の項目のサイズを変更する。
# 0 : 100% (default)    4294967295 : 100%               4294967294 : 100%               4294967293 : 100%
# 1 : 125%                       0 : 125% (default)     4294967295 : 125%               4294967294 : 125%
# 2 : 150%                       1 : 150%                        0 : 150% (default)     4294967295 : 150%
# 3 : 175%                       2 : 175%                        1 : 175%                        0 : 175% (default)
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet(0, 1, 2, 3, 4294967293, 4294967294, 4294967295)]
    [System.UInt32]$scaling = 0
)
$source = @’
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
                  uint uiAction,
                  uint uiParam,
                  uint pvParam,
                  uint fWinIni);
'@
Write-Host '変更しています。しばらくお待ちください。'
$apicall = Add-Type -MemberDefinition $source -Name WinAPICall -Namespace SystemParamInfo –PassThru
$apicall::SystemParametersInfo(0x009F, $scaling, $null, 1) | Out-Null
Write-Host '変更が完了しました。'
