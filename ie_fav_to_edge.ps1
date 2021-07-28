## Internet Explorer お気に入りパスを取得
[STRING]$IEpath = $([Environment]::GetFolderPath("Favorites"))
 
## Microsoft Edge お気に入りパス
[STRING]$EdgePath = $($env:LOCALAPPDATA + "\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\User\Default\Favorites")
 
## お気に入りレジストリパス
[string]$FavOrder = "HKCR:\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\FavOrder"
 
## パスの存在確認
if ((Test-Path -Path $IEpath) -and (Test-Path -Path $EdgePath)) {
 
    ## Internet Explorer から Edgeへお気に入りをコピーする
    Copy-Item -Path "$IEpath\*" -Destination $EdgePath -recurse -container -force -Exclude "`$RECYCLE.BIN" -ErrorAction SilentlyContinue

    ## HKEY_CLASSES_ROOTのマウント
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

    ## レジストリキーFavOrderが有効かどうかを確認
    if (Test-Path -Path $FavOrder)
    {
        # FavOrderをレジストリから削除
        Remove-Item -Path $FavOrder -Recurse
    }

    ## マウント解除
    Remove-PSDrive -Name HKCR
}
