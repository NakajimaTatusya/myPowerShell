<#
Install Language Pack for Windows Server 2019.
Mount-DiskImage
https://docs.microsoft.com/en-us/powershell/module/storage/mount-diskimage?view=windowsserver2022-ps
Write-Progress
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-progress?view=powershell-7.2
#>

[CmdletBinding()]
param (
    [string]$uri = 'https://software-download.microsoft.com/download/pr/17763.1.180914-1434.rs5_release_SERVERLANGPACKDVD_OEM_MULTI.iso',
    [string]$downloadpath = '.\iso\',
    [string]$saveisofilename = 'languagePack.iso',
    [string]$logdir = '.\logs\'
)

begin {
    # progress bar settings
    $totalStep = 3
    $counter = 0
    $denominator = ("/ {0} Step " -f $totalStep)
    $progress_per = 0.0

    # Enable debug output.
    $DebugPreference = 'Continue'
    $log_dir = $logdir
    $log_filename = Join-Path -Path $log_dir -ChildPath ("{0}_InstallLanguagePack_WinSvr2019_log.txt" -f ((Get-Date -Format "yyyy-MM-dd").ToString()))
    if (-not (Test-Path($log_dir))) {
        New-Item -Path $log_dir -ItemType Directory > $null
    }
    if (-not (Test-Path($downloadpath))) {
        New-Item -Path $downloadpath -ItemType Directory > $null
    }
    Write-Output $uri | Out-File -FilePath $log_filename -Encoding UTF8 -append
    Write-Output $downloadpath | Out-File -FilePath $log_filename -Encoding UTF8 -append
    $currentDir = (Convert-Path .)
    Write-Output $currentDir | Out-File -FilePath $log_filename -Encoding UTF8 -append
    $isofullpath = join-path -Path $currentDir -ChildPath $downloadpath | Join-Path -ChildPath $saveisofilename
    Write-Output $isofullpath | Out-File -FilePath $log_filename -Encoding UTF8 -append
}

process {
    $mflg = $false
    try {
        Write-Progress -Activity "progress" -Status ("{0} step {1}" -f $counter, $denominator) -PercentComplete 0

        $Now = Get-Date
        $start_datetime = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " Download language pack iso image -----"
        Write-Output $start_datetime | Out-File -FilePath $log_filename -Encoding UTF8 -append

        # download
        # Start-Sleep -s 10
        Write-Output $isofullpath | Out-File -FilePath $log_filename -Encoding UTF8 -append
        if (-not (Test-Path($isofullpath))) {
            Write-Output 'satrt downloading files.' | Out-File -FilePath $log_filename -Encoding UTF8 -append
            (New-Object System.Net.WebClient).DownloadFile($uri, $isofullpath)
        } else {
            Write-Output 'already file exsits. continue...' | Out-File -FilePath $log_filename -Encoding UTF8 -append
        }
        $counter = $counter + 1
        $progress_per = [Math]::Truncate($counter / $totalStep * 100)
        Write-Progress -Activity "progress" -Status ("{0} step {1}" -f $counter, $denominator) -PercentComplete $progress_per

        # $lpk_setup_path = ""
        
        # mount iso
        # Start-Sleep -s 10
        if (Test-Path($isofullpath)) {
            Write-Output 'Mount ISO disk image.' | Out-File -FilePath $log_filename -Encoding UTF8 -append
            $mnt_result = Mount-DiskImage -ImagePath $isofullpath -PassThru
            $mflg = $true
            # get dirve letter
            $drive_letter = ($mnt_result | Get-Volume).DriveLetter
            $lpk_setup_path = $drive_letter + ":\x64\langpacks\Microsoft-Windows-Server-Language-Pack_x64_ja-jp.cab"
            Write-Output $lpk_setup_path | Out-File -FilePath $log_filename -Encoding UTF8 -append
        } else {
            Write-Output 'iso image is not found.' | Out-File -FilePath $log_filename -Encoding UTF8 -append
        }
        $counter = $counter + 1
        $progress_per = [Math]::Truncate($counter / $totalStep * 100)
        Write-Progress -Activity "progress" -Status ("{0} step {1}" -f $counter, $denominator) -PercentComplete $progress_per

        # install language pack
        # Start-Sleep -s 10
        if (Test-Path($lpk_setup_path)) {
            $Now = Get-Date
            $startdatetime = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " Install language pack iso image -----"
            Write-Output $startdatetime | Out-File -FilePath $log_filename -Encoding UTF8 -append
            cmd /c C:\Windows\System32\lpksetup.exe /i ja-JP /f /s /p $lpk_setup_path
        } else {
            Write-Output 'Microsoft-Windows-Server-Language-Pack_x64_ja-jp.cab file is not found.' | Out-File -FilePath $log_filename -Encoding UTF8 -append
        }
        $counter = $counter + 1
        $progress_per = [Math]::Truncate($counter / $totalStep * 100)
        Write-Progress -Activity "progress" -Status ("{0} step {1}" -f $counter, $denominator) -PercentComplete $progress_per

        # delete old logs
        # Get-ChildItem -Filter '*log.txt' | Where-Object {($_.Mode -eq "-a----") -and ($_.CreationTime -lt (Get-Date).AddDays(-6))} | Remove-Item -recurse -force
    }
    catch {
        Write-Output $_.Exception.Message
        Write-Output $_.Exception.Message | Out-File -FilePath $log_filename -Encoding UTF8 -append
    }
    finally {
        if ($mflg) {
            Write-Output 'Unmount disk image.' | Out-File -FilePath $log_filename -Encoding UTF8 -append
            DisMount-DiskImage $isofullpath
        }
        $Now = Get-Date
        $startdatetime = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + "-----END-----"
        Write-Output $startdatetime | Out-File -FilePath $log_filename -Encoding UTF8 -append
    }
}

End {
    # # reboot
    # Write-Output 'Reboot.' | Out-File -FilePath $log_filename -Encoding UTF8 -append
    # #Restart-Computer -Force
}
