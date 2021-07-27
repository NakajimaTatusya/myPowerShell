<#
コマンドライン引数保存先のフォルダパス 

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
. .\data_migration_specialfolder.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
# 詳細出力有効
$VerbosePreference = "Continue"
# Debug出力有効
$DebugPreference = "Continue"


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
        [string]$configfilepath = '.\data_migration.conf'
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
                $FileInfoObj.DestinationPath = $_ -replace '^[A-Z]:', (Join-Path -Path $parentdir -ChildPath $backupfoldername)
                Get-ChildItem -Path $_ -File -Recurse | ForEach-Object {
                    $totalFileSize += $_.Length
                    $totalFileCount++
                }
                $FileInfoObj.TotalFileCount = $totalFileCount
                $totalSize = [decimal]("{0:N4}" -f ($totalFileSize / "1{0}" -f $scale))
                $FileInfoObj.TotalSize = "{0}{1}" -f $totalSize,$scale
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
パスを取得する
.DESCRIPTION
    スクリプト実行フォルダ
パスを取得する
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

# version check
$PSVersionTable
Write-Verbose $PSScriptRoot
$Informations = @()
$bkfldrnm = Get-BackupFolderName -ipv4 localhost

# スペシャルフォルダ
$names = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])
foreach($name in $names)
{
    if($path = [Environment]::GetFolderPath($name)){
        if ($TargetAlias.Contains($name)) {
            $Informations += Get-FileCountAndSize -SourcePath $path -Scale MB -backupfoldername $bkfldrnm
            # Get-ChildItem -Path $path -Recurse | Where-Object {$_.PSIsContainer} | ForEach-Object {
            #     if (![string]::IsNullOrEmpty($_.FullName)) {
            #         $Informations += Get-FileCountAndSize -SourcePath $_.FullName -Scale MB
            #     }
            # }
        }
    }
}
if ($TargetAlias.Contains("Download")) {
    $Informations += Get-FileCountAndSize -SourcePath (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path -Scale MB -backupfoldername $bkfldrnm
}

# 個別フォルダ
if ($IndividualTarget) {
    foreach ($path in $IndividualTarget) {
        if (![string]::IsNullOrEmpty($path)) {
            $Informations += Get-FileCountAndSize -SourcePath $path -Scale MB -backupfoldername $bkfldrnm
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
    Write-Output "個別設定がないか、設定ファイルが読み込めませんでした。"
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
$outputfile = Join-Path -Path $parentdir -ChildPath ("{0}.csv" -f $bkfldrnm)
$Informations | Export-Csv -Path $outputfile -Encoding Default -NoTypeInformation

# 戻す設定ファイル
$restorefile = Join-Path -Path $parentdir -ChildPath ("{0}.conf" -f $bkfldrnm)
$Informations `
    | Select-Object -Property @{Name = 'SourcePath'; Expression = {$_.DestinationPath}}, @{Name = 'DestinationPath'; Expression = {$_.SourcePath -replace $env:UserName, '{0}'}} `
    | Export-Csv -Path $restorefile -Encoding Default -NoTypeInformation

exit 0
