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

# Import config
. .\Backup_for_data_migration_specialfolder.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
# 詳細出力有効
$VerbosePreference = "Continue"
# Debug出力有効
$DebugPreference = "Continue"


function Log {
<#
.SYNOPSIS
    本Powershellスクリプトのログを出力する
.DESCRIPTION
    与えられた文字列をアプリケーションログとして出力する
.PARAMETER LogString
    出力するログ文字列
.EXAMPLE
    $ret = Log -LogString "hogehoge"
.INPUTS
    String
.OUTPUTS
    String
.NOTES
    Author:  Tatsuya Nakajima
    Website: https://github.com/NakajimaTatusya/myPowerShell.git
#>
    param ([Parameter(Mandatory = 1)][string]$LogString)
    
    process {
        $LogPath = Get-CurrentDirectoryPath
        $LogName = "BackupForDataMigration"
        $Now = Get-Date
        # Log 出力文字列に時刻を付加(YYYY/MM/DD HH:MM:SS.MMM $LogString)
        $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "
        $Log += $LogString
        $LogFile = "{0}_{1}.log" -f $LogName, $Now.ToString("yyyy-MM-dd")
        $LogFileName = Join-Path $LogPath $LogFile
        Write-Output $Log | Out-File -FilePath $LogFileName -Encoding Default -append
        # echo back
        Return $Log
    }
}


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
        [string]$configfilepath = '.\Backup_for_data_migration.conf'
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


function Get-BackupFolderName {
<#
.SYNOPSIS
    出力ファイル名に使用するホスト名を取得する
.DESCRIPTION
    IPv4からホスト名を取得する
.PARAMETER ipv4
    IPv4アドレス文字列
.EXAMPLE
     Get-BackupFolderName -ipv4 127.0.0.1
     Get-BackupFolderName -ipv4 localhost
.INPUTS
    String
.OUTPUTS
    string
.NOTES
    Author:  Tatsuya Nakajima
    Website: https://github.com/NakajimaTatusya/myPowerShell.git
#>
    [cmdletbinding()]
    param
    (
        [parameter(
            position = 0,
            Mandatory = 1
        )]
        [string]$ipv4
    )

    begin {
        [string]$hostname = ""
        $dt = (Get-Date -Format "yyyyMMdd_HHmmss").ToString()
    }

    process {
        try {
            Write-Verbose 'get HOSTNAME ...'
            [System.Net.IPHostEntry]$he = [System.Net.Dns]::GetHostEntry($ipv4)
            $hostname = $he.HostName
        }
        catch {
            $hostname = 'unknownhost'
            Write-Output $_.Exception.Message
        }
        return ("{0}_{1}" -f $hostname, $dt)
    }
}


function Get-FileCountAndSize {
<#
.SYNOPSIS
    データ移行で使用する。ROBOCOPYへバックアップ対処のパスを渡す
.DESCRIPTION
    ファイル総数、ファイル総サイズを算出する
.PARAMETER Path
    調査対象のパス
.PARAMETER Scale
    容量の単位（KB,MB,GB）
.EXAMPLE
     Get-FileCountAndSize -SourcePath $path -Scale MB
.INPUTS
    String
    validateSet
.OUTPUTS
    PSObject
.NOTES
    Author:  Tatsuya Nakajima
    Website: https://github.com/NakajimaTatusya/myPowerShell.git
#>
    [CmdletBinding()]
    param
    (
        [parameter(
            position = 0,
            mandatory = 1,
            valuefrompipeline = 1,
            valuefrompipelinebypropertyname = 1)]
        [string[]]
        $SourcePath,

        [parameter(
            position = 1,
            mandatory = 0,
            valuefrompipelinebypropertyname = 1)]
        [validateSet("KB", "MB", "GB")]
        [string]
        $Scale = "KB",

        [parameter(
            position = 2,
            Mandatory = 0,
            valuefrompipelinebypropertyname = 1)]
            [string]
            $backupfoldername
    )

    process {
        [decimal] $totalFileCount = 0
        [decimal] $totalFileSize = 0
        $FileInfoObj = @{}
        $SourcePath `
        | ForEach-Object{
            if (Test-Path $_) {
                $FileInfoObj = New-Object PSObject | Select-Object SourcePath,DestinationPath,TotalFolderCount,TotalFileCount,TotalSize
                $FileInfoObj.SourcePath = $_
                $FileInfoObj.DestinationPath = $_ -replace '^[A-Z]:', $backupfoldername
                Get-ChildItem -Path $_ -File -Recurse | ForEach-Object {
                    $totalFileSize += $_.Length
                    $totalFileCount++
                }
                $FileInfoObj.TotalFileCount = $totalFileCount
                $totalSize = [decimal]("{0:N2}" -f ($totalFileSize / "1{0}" -f $scale))
                $FileInfoObj.TotalSize = "{0}{1}" -f $totalSize, $scale
                $FileInfoObj.TotalFolderCount = (Get-ChildItem -Path $_ -Directory -Recurse | Measure-Object).Count
            }
        }
        return $FileInfoObj
    }
}


function Get-CurrentDirectoryPath {
<#
.SYNOPSIS
    スクリプト実行フォルダ
.DESCRIPTION
    スクリプト実行フォルダ
.EXAMPLE
     Get-CurrentDirectoryPath
.INPUTS
    void
.OUTPUTS
    string
.NOTES
    Author:  Tatsuya Nakajima
    Website: https://github.com/NakajimaTatusya/myPowerShell.git
#>
        # PS v3
        if ($PSVersionTable.PSVersion.Major -ge 3) {
            $retval = $PSScriptRoot
        }
        # PS v2
        else {
            $retval = Split-Path $MyInvocation.MyCommand.Path -Parent
        }
        return $retval
}


function ExecRobocopy {
<#
.SYNOPSIS
    新しいパソコンへデータ移行するために、Robocopy ユーティリティを起動し、バックアップを実施する
.DESCRIPTION
    Robocopy ユーティリティを起動し、バックアップを実施する
.PARAMETER src
    コピー元パス
.PARAMETER dst
    コピー先パス
.PARAMETER logfile
    Robocopy が出力するログファイルのパス
.EXAMPLE
    $resultObj = ExecRobocopy -src $item.SourcePath -dst $item.DestinationPath -logfile $robocopylogfile
.INPUTS
    String
    String
    String
.OUTPUTS
    PSObject
.NOTES
    Author:  Tatsuya Nakajima
    Website: https://github.com/NakajimaTatusya/myPowerShell.git

    戻り値 0: コピーする必要がないため、何も実施しなかった
    戻り値 1: ファイルのコピーが成功した (フォルダーのコピーは含まれません)
    戻り値 2: 余分なフォルダー、ファイルが確認された (コピー元にはなく、コピー先だけにある) 
    戻り値 4: 同じ名前で別の種類のファイルが存在した (コピー元はフォルダーで、コピー先はファイル、またはその逆)
    戻り値 8: コピーに失敗した (リトライした結果を含みます、また /L では実際にコピー処理を行わないため、実質 8 以上の戻り値は出力されません)
    このそれぞれの戻り値は LOG オプションでカウントされる場所は以下となります。
    0 と判定されたファイル、フォルダーはログ中の "スキップ" にカウントされます。
    1 と判定されたファイル、フォルダーはログ中の "コピー済み" にカウントされます。
    2 と判定されたファイル、フォルダーはログ中の "Extras" にカウントされます。
    4 と判定されたファイル、フォルダーはログ中の "不一致" にカウントされます。
    8 と判定されたファイル、フォルダーはログ中の "失敗" にカウントされます。
    しかし、robocopy の Log ファイルをご覧いただいた事のある方であれば、戻り値が 9 以上となっている結果をご覧いただいたことがあるかもしれません。
    これは、複数のファイル、フォルダーをコピーされる場合に別々の結果となった場合に、足し算された値が返されるためです。
    例えば、戻り値が [1] の場合には、robocopy によって処理されたファイルが、すべて正常に "コピー済み" と判断された場合です。
    戻り値が [3] の場合、robocopy によって処理されたファイルの中に、戻り値 1 である "コピー済み" と戻り値 2 である "Extras" と判断されたファイルが混在する場合に記録されます。
    つまり、戻り値が [1] 以外となっている場合には、正常にコピーが完了しなかったファイルが存在していることを表します。
    以下に、[1] 以外のそれぞれの戻り値の結果をご紹介いたしますので、ご参考願います。
    戻り値 3: 一部のファイルのコピーに成功したが、一部、Extras と判定された。(1 + 2)
    戻り値 5: 一部のファイルのコピーに成功したが、一部、不一致 と判定された。(1 + 4)
    戻り値 6: ファイルのコピーに成功しておらず、Extras または 不一致 と判定された (2 + 4)
    戻り値 7: 一部のファイルのコピーに成功したが、一部 Extras または 不一致 と判定された (1 + 2 + 4)
    戻り値 9: 一部のファイルのコピーに成功したが、一部 失敗 と判定された (1 + 8)
    戻り値 10: ファイルのコピーに成功しておらず、Extras または 失敗 と判定された (2 + 8)
    戻り値 11: 一部のファイルのコピーに成功したが、一部 Extras または 失敗 と判定された (1 + 2 + 8)
    戻り値 12: ファイルのコピーに成功しておらず、不一致 または 失敗 と判定された (4 + 8)
    戻り値 13: 一部のファイルのコピーに成功したが、一部 不一致 または 失敗 と判定された (1 + 4 + 8)
    戻り値 14: ファイルのコピーに成功しておらず、Extras、不一致 または 失敗 と判定された (2 + 4 + 8)
    戻り値 15: 一部のファイルのコピーに成功したが、一部 Extras、不一致 または 失敗 と判定された (1 + 2 + 4 + 8)
    戻り値 16: ヘルプを表示したときにセットされます。また、存在しないフォルダーなどを指定するなど、引数が不正な場合にも記録されます。
#>
    [CmdletBinding()]
    param (
        [parameter(
            position = 0,
            mandatory = 1)]
        [string]
        $src,
        [parameter(
            position = 1,
            mandatory = 1)]
        [string]
        $dst,
        [parameter(
            position = 2,
            mandatory = 1)]
        [string]
        $logfile
    )
    process {
        $retobj = @{}
        $retobj = New-Object PSObject | Select-Object code,msg
        $commandString = 'robocopy "{0}" "{1}" /E /NP /R:0 /ETA /LOG+:"{2}"' -f $src, $dst, $logfile
        Write-Verbose $commandString
        $retval = cmd /c $commandString
        if ($retval) {
            if ($retval -eq 1) {
                $retobj.code = 1
                $retobj.msg = "ファイルのコピーが成功した。"
            }
            elseif ($retval -eq 2) {
                $retobj.code = $retval
                $retobj.msg = "余分なフォルダー、ファイルが確認された。"
            }
            elseif ($retval -eq 3) {
                $retobj.code = $retval
                $retobj.msg = "一部のファイルのコピーに成功したが、一部、Extras と判定された。"
            }
            elseif ($retval -eq 4) {
                $retobj.code = $retval
                $retobj.msg = "同じ名前で別の種類のファイルが存在した。"
            }
            elseif ($retval -eq 5) {
                $retobj.code = $retval
                $retobj.msg = "一部のファイルのコピーに成功したが、一部、不一致 と判定された。"
            }
            elseif ($retval -eq 6) {
                $retobj.code = $retval
                $retobj.msg = "ファイルのコピーに成功しておらず、Extras または 不一致 と判定された。"
            }
            elseif ($retval -eq 7) {
                $retobj.code = $retval
                $retobj.msg = "一部のファイルのコピーに成功したが、一部 Extras または 不一致 と判定された。"
            }
            elseif ($retval -eq 8) {
                $retobj.code = $retval
                $retobj.msg = "コピーに失敗した。"
            }
            elseif ($retval -eq 9) {
                $retobj.code = $retval
                $retobj.msg = "一部のファイルのコピーに成功したが、一部 失敗 と判定された。"
            }
            elseif ($retval -eq 10) {
                $retobj.code = $retval
                $retobj.msg = "ファイルのコピーに成功しておらず、Extras または 失敗 と判定された。"
            }
            elseif ($retval -eq 11) {
                $retobj.code = $retval
                $retobj.msg = "一部のファイルのコピーに成功したが、一部 Extras または 失敗 と判定された。"
            }
            elseif ($retval -eq 12) {
                $retobj.code = $retval
                $retobj.msg = "ファイルのコピーに成功しておらず、不一致 または 失敗 と判定された。"
            }
            elseif ($retval -eq 13) {
                $retobj.code = $retval
                $retobj.msg = "一部のファイルのコピーに成功したが、一部 不一致 または 失敗 と判定された。"
            }
            elseif ($retval -eq 14) {
                $retobj.code = $retval
                $retobj.msg = "ファイルのコピーに成功しておらず、Extras、不一致 または 失敗 と判定された。"
            }
            elseif ($retval -eq 15) {
                $retobj.code = $retval
                $retobj.msg = "一部のファイルのコピーに成功したが、一部 Extras、不一致 または 失敗 と判定された。"
            }
            elseif ($retval -eq 16) {
                $retobj.code = $retval
                $retobj.msg = "不正な引数を指定した。"
            }
            else {
                $retobj.code = 0
                $retobj.msg = "何も実施しなかった。"
            }
        }
        return $retobj
    }
}


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

# version display
$PSVersionTable
Write-Verbose $PSScriptRoot
$Informations = @()
$bkfldrnm = Get-BackupFolderName -ipv4 localhost

# バックアップフォルダが無い場合作成する
$backupfolder = join-path -path $parentdir -ChildPath $bkfldrnm
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
    $Informations += Get-FileCountAndSize -SourcePath (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path -Scale MB -backupfoldername $backupfolder
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
# OutPut CSV.
$outputfile = Join-Path -Path $backupfolder -ChildPath ("{0}.csv" -f $bkfldrnm)
$Informations | Export-Csv -Path $outputfile -Encoding Default -NoTypeInformation

# 戻す設定ファイル
$restorefile = Join-Path -Path $backupfolder -ChildPath ("{0}.conf" -f $bkfldrnm)
$Informations `
    | Select-Object -Property @{Name = 'SourcePath'; Expression = {$_.DestinationPath}}, @{Name = 'DestinationPath'; Expression = {$_.SourcePath -replace $env:UserName, '{0}'}} `
    | Export-Csv -Path $restorefile -Encoding Default -NoTypeInformation

while ($userinput = (Read-Host "バックアップを開始します。よろしいですか？(Y/n)")) {
    if ($userinput -ceq "Y") { break }
    elseif ($userinput -ceq "n") { exit 0 }
    else { Write-Output "「Y」または「n」を入力してください。（大文字小文字を区別します。）" }
}

Write-Output "***** バックアップ開始 *****"
$robocopylogfile = Join-Path -Path $backupfolder -ChildPath ("{0}_robocopy.log" -f ((Get-Date -Format "yyyy-MM-dd").ToString()))
if ($userinput -ceq "Y") {
    foreach ($item in $Informations) {
        $resultObj = ExecRobocopy -src $item.SourcePath -dst $item.DestinationPath -logfile $robocopylogfile
        log -LogString ("EXECUTE ROBOCOPY ResultCode={0} ResultMessage:{1} CopyFrom:[{2}] CopyTo:[{3}]" -f $resultObj.code, $resultObj.msg, $item.SourcePath, $item.DestinationPath)
    }
}
Write-Output "***** バックアップ終了 *****"

exit 0
