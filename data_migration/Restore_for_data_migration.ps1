
Param (
    [string]$parentdir,
    [string]$settingsfile
)

Import-Module -Name ..\library\AppCommon.psm1 -Force

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

# パラメータチェック
if ($settingsfile) {
    if (-not (Test-Path -Path $settingsfile)) {
        Write-Error "設定ファイルが見つかりません"
        exit -1
    }
}
else {
    Write-Verbose ".\restore_conf\の設定ファイルを探す"
    $wk = (Get-ChildItem -Path ".\restore_conf\" | Where-Object {$_.Name -match '^restore_.*\.conf$'} | Sort-Object -Descending -Property LastWriteTime | Select-Object Name, FullName -First 1)
    if ($wk) {
        $settingsfile = $wk.FullName
        if (-not (Test-Path -Path $settingsfile)) {
            Write-Error "設定ファイルが見つかりません"
            exit -1
        }
    }
    else {
        Write-Error "設定ファイルが見つかりません"
        exit -1
    }
}
if ($parentdir) {
    if (!(Test-Path($parentdir))) {
        $parentdir = Get-CurrentDirectoryPath
    }
}
else {
    $parentdir = Get-CurrentDirectoryPath
}

# Logging
$logPath = Join-Path (Get-CurrentDirectoryPath) "data_migration_logs"
$logName = "RestoreForDataMigration"


Write-Verbose "CSV取り込み開始"
$Informations = @()
$configurations = Import-Csv $settingsfile -Encoding Default
$configurations | Format-Table
Write-Verbose ("取り込んだ行数:{0}行" -f $configurations.count)
Write-Verbose "復元先の情報を収集"
foreach ($item in $configurations) {
    Log -LogPath $logPath -LogName $logName -LogString ("src:[{0}]    dst[{1}]" -f $item.SourcePath, ($item.DestinationPath -f $env:USERNAME))
    $Informations += Get-FileCountAndSize -SourcePath ($item.DestinationPath -f $env:USERNAME) -Scale MB
}
Write-Verbose "CSV取り込み終了"

$dt = (Get-Date -Format "yyyyMMdd_HHmmss").ToString()
$cmpnm = Get-BackupFolderName -ipv4 localhost
$informationfolder = Join-Path $parentdir "restore_data_migration" | Join-Path -ChildPath $cmpnm | Join-Path -ChildPath $dt
if (-not (Test-Path($informationfolder))) {
    New-Item -Path $informationfolder -ItemType Directory > $null
}

# Output table on screen.
$Informations | ForEach-Object {[PSCustomObject]$_} `
    | Format-Table `
    @{label='CopyTo';expression={$_.SourcePath};width=60;alignment='left';}, `
    @{label='TotalFolderCount';expression={$_.TotalFolderCount};width=20;alignment='right';}, `
    @{label='TotalFileCount';expression={$_.TotalFileCount};width=20;alignment='right';}, `
    @{label='TotalFileSize';expression={$_.TotalSize};width=20;alignment='right';}
# コピー先情報出力
$outputfile = Join-Path -Path $informationfolder -ChildPath ("復元先_{0}.csv" -f $cmpnm)
$Informations `
    | Select-Object -Property @{Name = '復元先'; Expression = {$_.SourcePath}}, @{Name = '合計フォルダ数'; Expression = {$_.TotalFolderCount}}, @{Name = '合計ファイル数'; Expression = {$_.TotalFileCount}}, @{Name = '合計ファイルサイズ'; Expression = {$_.TotalSize}} `
    | Export-Csv -Path $outputfile -Encoding Default -NoTypeInformation

Log -LogPath $logPath -LogName $logName -LogString "***** 復元前のコピー先情報を出力しました *****"

while ($userinput = (Read-Host "レストアを開始します。よろしいですか？(大文字小文字を区別します)[Y/n]")) {
    if ($userinput -ceq "Y") { 
        break 
    }
    elseif ($userinput -ceq "n") { 
        Log -LogPath $logPath -LogName $logName -LogString "***** ユーザー操作により処理を中止します *****"
        exit 0 
    }
    else { 
        Write-Output "「Y」または「n」を入力してください。（大文字小文字を区別します）" 
    }
}

Log -LogPath $logPath -LogName $logName -LogString "***** 復元開始 *****"
$robocopylogfile = Join-Path -Path $informationfolder -ChildPath ("{0}_robocopy.log" -f ((Get-Date -Format "yyyy-MM-dd").ToString()))
if ($userinput -ceq "Y") {
    foreach ($item in $Informations) {
        $resultObj = ExecRobocopy -src $item.SourcePath -dst $item.DestinationPath -logfile $robocopylogfile
        Log -LogPath $logPath -LogName $logName -LogString ("EXECUTE ROBOCOPY ResultCode={0} ResultMessage:{1} CopyFrom:[{2}] CopyTo:[{3}]" -f $resultObj.code, $resultObj.msg, $item.SourcePath, $item.DestinationPath)
    }
}
Log -LogPath $logPath -LogName $logName -LogString "***** 復元終了 *****"

Log -LogPath $logPath -LogName $logName -LogString "End Restore for data migration. *****"

exit 0
