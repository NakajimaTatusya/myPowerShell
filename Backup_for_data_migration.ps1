<#
.SYNOPSIS
    古いパソコンから新しいパソコンへデータ移行を行うために、USBメモリへスペシャルフォルダおよび特定のフォルダのサブフォルダ、ファイルをバックアップする
.DESCRIPTION
    スペシャルフォルダおよび特定のフォルダのサブフォルダ、ファイルをバックアップする
.PARAMETER parentdir
    レストア設定ファイルとバックアップ先の親フォルダパス
.PARAMETER confpath
    設定ファイルのパス
.EXAMPLE
    data_migration.ps1 -parentdir c:\temp -confpath .\data_migration.conf
.INPUTS
    String, string
.OUTPUTS
    int
    csv file
    conf file
.NOTES
    Author:  Tatsuya Nakajima
    Website: https://github.com/NakajimaTatusya/myPowerShell.git

    One-Point advice
    1次元のオブジェクト配列はJsonにすると、配列ではなくなるので、2番目のConvertTo-Jsonのような使い方をすること
    $arrays = @(@{a=1;b=2;})
    $arrays | ConvertTo-Json
    ConvertTo-Json $arrays
#>
param (
    [string]$parentdir,
    [string]$confpath
)

Import-Module -Name .\library\AppCommon.psm1 -Force

# Import config
. .\backup_conf\Backup_for_data_migration_specialfolder.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

# Logging
$logPath = Join-Path (Get-CurrentDirectoryPath) "data_migration_logs"
$logName = "BackupForDataMigration"


function Read-DataMigrationConfig {
<#
.SYNOPSIS
    スペシャルフォルダ以外のデータをバックアップするために、設定ファイルにフルパスを保存し、それを読み込んで配列に入れて返す。
.DESCRIPTION
    個別バックアップ対象のフルパスを設定ファイルから取得する。
.PARAMETER configfilepath
    設定ファイルのパス
.EXAMPLE
    Read-DataMigrationConfig -configfilepath c:\temp
    Read-DataMigrationConfig
.INPUTS
    String
.OUTPUTS
    array
.NOTES
    Author:  Tatsuya Nakajima
    Website: https://github.com/NakajimaTatusya/myPowerShell.git
#>
    [cmdletbinding()]
    param
    (
        [string]$configfilepath = '.\backup_conf\Backup_for_data_migration.conf'
    )

    Begin {
        $retval = @()
    }

    process {
        try {
            $file = New-Object System.IO.StreamReader($configfilepath, [System.Text.Encoding]::GetEncoding("sjis"))
            while ($null -ne ($line = $file.ReadLine()))
            {
                $retval += $line
            }
        }
        catch {

        }
        return $retval
    }
}


Log -LogPath $logPath -LogName $logName -LogString "start Backup for data migration. *****"
# 設定ファイル読み込み
$IndividualTarget = @()
if ($confpath) {
    if (Test-Path($confpath)) {
        $IndividualTarget = Read-DataMigrationConfig -configfilepath $confpath
    }
}
else {
    $IndividualTarget = Read-DataMigrationConfig
}
# 出力フォルダ設定
if ($parentdir) {
    if (!(Test-Path($parentdir))) {
        $parentdir = Get-CurrentDirectoryPath
    }
}
else {
    $parentdir = Get-CurrentDirectoryPath
}

Log -LogPath $logPath -LogName $logName -LogString ("PowerShell current Version is {0}." -f $PSVersionTable.PSVersion)
$dt = (Get-Date -Format "yyyyMMdd_HHmmss").ToString()
Write-Verbose $PSScriptRoot
$Informations = @()
$bkfldrnm = Get-BackupFolderName -ipv4 localhost

# バックアップフォルダが無い場合作成する
$backupfolder = Join-Path $parentdir "backup_data_migration" | Join-Path -ChildPath $bkfldrnm | Join-Path -ChildPath $dt
if (!(Test-Path($backupfolder))) {
    # 戻り値をNULL破棄するために>$nullを使用、処理スピード最速
    New-Item $backupfolder -ItemType Directory > $null
}

# スペシャルフォルダ
$names = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])
foreach($name in $names)
{
    if($path = [Environment]::GetFolderPath($name)){
        if ($TargetAlias.Contains($name)) {
            $Informations += Get-FileCountAndSize -SourcePath $path -Scale MB -backupfoldername $backupfolder
            # Get-ChildItem -Path $path -Recurse | Where-Object {$_.PSIsContainer} | ForEach-Object {
            #     if (![string]::IsNullOrEmpty($_.FullName)) {
            #         $Informations += Get-FileCountAndSize -SourcePath $_.FullName -Scale MB
            #     }
            # }
        }
    }
}
if ($TargetAlias.Contains("Download")) {
    $Informations += Get-FileCountAndSize -SourcePath (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path `
                                          -Scale MB -backupfoldername $backupfolder
}

# 個別フォルダ
if ($IndividualTarget) {
    foreach ($path in $IndividualTarget) {
        if (![string]::IsNullOrEmpty($path)) {
            $Informations += Get-FileCountAndSize -SourcePath $path -Scale MB -backupfoldername $backupfolder
        }
        # recurse
        # Get-ChildItem -Path $path -Recurse | Where-Object {$_.PSIsContainer} | ForEach-Object {
        #     if (![string]::IsNullOrEmpty($_.FullName)) {
        #         $Informations += Get-FileCountAndSize -SourcePath $_.FullName -Scale MB
        #     }
        # }
    }
}
else {
    Write-Information "個別設定フォルダは対象外となりました。##個別設定がないか、個別設定ファイルが読み込めませんでした##"
}

# Output table on screen.
# $Informations | ForEach-Object {[PSCustomObject]$_} `
#     | Format-Table `
#     @{label='TargetDirectory';expression={$_.SourcePath};width=60;alignment='left';}, `
#     @{label='TargetDirectory';expression={$_.DestinationPath};width=60;alignment='left';}, `
#     @{label='TotalFolderCount';expression={$_.TotalFolderCount};width=20;alignment='right';}, `
#     @{label='TotalFileCount';expression={$_.TotalFileCount};width=20;alignment='right';}, `
#     @{label='TotalFileSize';expression={$_.TotalSize};width=20;alignment='right';}
# Output Json on screen.
# ConvertTo-Json $Informations

# コピー元情報出力
$outputfile = Join-Path -Path $backupfolder -ChildPath "コピー元フォルダファイル情報一覧.csv"
$Informations `
    | Select-Object -Property @{Name = 'コピー元'; Expression = {$_.SourcePath}}, @{Name = '合計フォルダ数'; Expression = {$_.TotalFolderCount}}, @{Name = '合計ファイル数'; Expression = {$_.TotalFileCount}}, @{Name = '合計ファイルサイズ'; Expression = {$_.TotalSize}} `
    | Export-Csv -Path $outputfile -Encoding Default -NoTypeInformation

# Restore設定ファイル出力
$restorefile = Join-Path -Path ".\restore_conf\" -ChildPath ("restore_{0}_{1}.conf" -f $bkfldrnm, $dt)
$Informations `
    | Select-Object -Property @{Name = 'SourcePath'; Expression = {$_.DestinationPath}}, @{Name = 'DestinationPath'; Expression = {$_.SourcePath -replace $env:UserName, '{0}'}} `
    | Export-Csv -Path $restorefile -Encoding Default -NoTypeInformation

Log -LogPath $logPath -LogName $logName -LogString "***** バックアップ対象の情報を取得し、csvファイル、confファイルに出力しました *****"

while ($userinput = (Read-Host "バックアップを開始します。よろしいですか？(大文字小文字を区別します)[Y/n]")) {
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

Log -LogPath $logPath -LogName $logName -LogString "***** バックアップ開始 *****"
$robocopylogfile = Join-Path -Path $backupfolder -ChildPath ("{0}_robocopy.log" -f ((Get-Date -Format "yyyy-MM-dd").ToString()))
if ($userinput -ceq "Y") {
    foreach ($item in $Informations) {
        $resultObj = ExecRobocopy -src $item.SourcePath -dst $item.DestinationPath -logfile $robocopylogfile
        Log -LogPath $logPath -LogName $logName -LogString ("EXECUTE ROBOCOPY ResultCode={0} ResultMessage:{1} CopyFrom:[{2}] CopyTo:[{3}]" -f $resultObj.code, $resultObj.msg, $item.SourcePath, $item.DestinationPath)
    }
}
Log -LogPath $logPath -LogName $logName -LogString "***** バックアップ終了 *****"

Log -LogPath $logPath -LogName $logName -LogString "End Backup for data migration. *****"
exit 0
