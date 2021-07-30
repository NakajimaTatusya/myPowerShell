<#
.SYNOPSIS
    古いパソコン、または古いUserProfileから、新しいパソコン、新しいUserProfileへ、Google Chromeのお気に入り、履歴、設定情報を丸ごと移動する
.DESCRIPTION
    Google Chromeのお気に入り、設定、履歴をバックアップしレストアする
.PARAMETER RESTORE
    RESTOREを指定すると、バックアップしたブックマーク、履歴、設定をリストア
    RESTOREを指定すると、Google Chromeのブックマーク、履歴、設定をバックアップ
.EXAMPLE
    Moving_favorities_newChrome.ps1 -BACKUP    バックアップ処理
    Moving_favorities_newChrome.ps1            リストア処理
.INPUTS
    switch
.OUTPUTS
    int
.NOTES
    Author:  Tatsuya Nakajima
    Website: https://github.com/NakajimaTatusya/myPowerShell.git
#>
param ([switch]$RESTORE)

begin {
    Import-Module -Name ..\library\AppCommon.psm1 -Force

    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"
    $WarningPreference = "Continue"
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"

    Set-Variable googleChromePath -Option Constant -Value "Google\Chrome\User Data\Default"
    Set-Variable gcUserDataBackupPath -Option Constant -Value "google_chrome_userdata_backup"

    $logPath = Join-Path (Get-CurrentDirectoryPath) "moving_chrome_logs"
    $logName = "MovingFavoritiesNewChrome"
    Log -LogPath $logPath -LogName $logName -LogString "Start Moving favorities to new chrome. *****"
}

process {
    $googleChromeDefaultPath = Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) $googleChromePath
    Log -LogPath $logPath -LogName $logName -LogString $googleChromeDefaultPath
    if (-not (Test-Path($googleChromeDefaultPath))) {
        Log -LogPath $logPath -LogName $logName -LogString "Google Chrome ユーザーデータパスが見つかりません。終了します。"
        exit -1
    }

    if ($RESTORE) {
        # Google Chrome のブックマーク、履歴、設定をリストア
        while ($userinput = (Read-Host "リストアを開始します。よろしいですか？(大文字小文字を区別します)[Y/n]")) {
            if ($userinput -ceq "Y") {
                break 
            }
            elseif ($userinput -ceq "n") { 
                Log -LogPath $logPath -LogName $logName -LogString "***** ユーザー操作により処理を中止します *****"
                exit 1
            }
            else { 
                Write-Output "「Y」または「n」を入力してください。（大文字小文字を区別します）" 
            }
        }

        Log -LogPath $logPath -LogName $logName -LogString "***** リストア開始 *****"
        $bkfolder = (Get-ChildItem -Path (Join-Path (Get-CurrentDirectoryPath) $gcUserDataBackupPath) `
                    | Sort-Object -Property Name -Descending | Select-Object FullName -First 1)
        $robocopylogfile = Join-Path -Path $logPath -ChildPath ("re_{0}_robocopy.log" -f ((Get-Date -Format "yyyy-MM-dd").ToString()))
        $resultObj = ExecRobocopy -src $bkfolder -dst $googleChromeDefaultPath -logfile $robocopylogfile
        Log -LogPath $logPath -LogName $logName -LogString ("EXECUTE ROBOCOPY ResultCode={0} ResultMessage:{1} CopyFrom:[{2}] CopyTo:[{3}]" -f $resultObj.code, $resultObj.msg, $bkfolder, $googleChromeDefaultPath)
        Log -LogPath $logPath -LogName $logName -LogString "***** リストア終了 *****"
    }
    else {
        # Google Chrome のブックマーク、履歴、設定をバックアップ
        while ($userinput = (Read-Host "バックアップを開始します。よろしいですか？(大文字小文字を区別します)[Y/n]")) {
            if ($userinput -ceq "Y") { 
                break 
            }
            elseif ($userinput -ceq "n") { 
                Log -LogPath $logPath -LogName $logName -LogString "***** ユーザー操作により処理を中止します *****"
                exit 1
            }
            else { 
                Write-Output "「Y」または「n」を入力してください。（大文字小文字を区別します）" 
            }
        }

        $Now = Get-Date
        $bkfolder = Join-Path (Get-CurrentDirectoryPath) $gcUserDataBackupPath | Join-Path -ChildPath ($Now.ToString("yyyyMMdd-HHmmss"))
        if (-not (Test-Path($bkfolder))) {
            New-Item -Path $bkfolder -ItemType Directory > $null
        }
        Log -LogPath $logPath -LogName $logName -LogString "***** バックアップ開始 *****"
        $robocopylogfile = Join-Path -Path $logPath -ChildPath ("bk_{0}_robocopy.log" -f ((Get-Date -Format "yyyy-MM-dd").ToString()))
        $resultObj = ExecRobocopy -src $googleChromeDefaultPath -dst $bkfolder -logfile $robocopylogfile
        Log -LogPath $logPath -LogName $logName -LogString ("EXECUTE ROBOCOPY ResultCode={0} ResultMessage:{1} CopyFrom:[{2}] CopyTo:[{3}]" -f $resultObj.code, $resultObj.msg, $googleChromeDefaultPath, $bkfolder)
        Log -LogPath $logPath -LogName $logName -LogString "***** バックアップ終了 *****"
    }
}

end {
    Log -LogPath $logPath -LogName $logName -LogString "End Moving favorities to new chrome. *****"
    exit 0
}
