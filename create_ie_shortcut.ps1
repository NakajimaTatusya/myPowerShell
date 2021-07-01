<#
新規にピン留めする
#>
Function New-PinnedItem {
    [CmdletBinding()]
    param (
        [ValidateScript( { $_.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -eq -1 })]
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(Mandatory, ParameterSetName = 'Command')]
        [String]$Name,
        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [String]$Path,
        [Parameter(Mandatory, ParameterSetName = 'Command')]
        [scriptblock]$Command,
        [ValidateSet('Normal', 'Minimized', 'Maximized')]
        [String]$WindowStyle = 'Normal',
        [String]$Arguments,
        [String]$Description,
        [String]$Hotkey,
        [String]$IconLocation,
        [Switch]$RunAsAdmin,
        [String]$WorkingDirectory,
        [String]$RelativePath
    )
    $NoExtension = [System.IO.Path]::GetExtension($path) -eq ""
    $pinHandler = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.taskbarpin" -Name "ExplorerCommandHandler"
    New-Item -Path "HKCU:Software\Classes\*\shell\pin" -Force | Out-Null
    Set-ItemProperty -LiteralPath "HKCU:Software\Classes\*\shell\pin" -Name "ExplorerCommandHandler" -Type String -Value $pinHandler

    if ($PSCmdlet.ParameterSetName -eq 'Command') {
        #$Path = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
        $Path = "powershell.exe"
        $Arguments = ('-NoProfile -Command "&{{{0}}}"' -f ($Command.ToString().Trim("`r`n") -replace "`r`n", ';'))
        if (!$PsBoundParameters.ContainsKey('WindowStyle')) {
            $WindowStyle = 'Minimized'
        }
    }

    if (!(Test-Path -Path $Path)) {
        if ($NoExtension) {
            $Path = "$Path.exe"

        }
        $Found = $False
        $ShortName = [System.IO.Path]::GetFileNameWithoutExtension($path)
        # testing against installed programs (Registry)
        $loc = Get-ChildItem HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
        $names = ($loc | foreach-object { Get-ItemProperty $_.PsPath }).Where( { ![String]::IsNullOrWhiteSpace($_.InstallLocation) })
        $InstallLocations1, $InstallLocations2 = $names.Where( { $_.DisplayName -Like "*$ShortName*" }, 'split') 
        $InstallLocations1 = $InstallLocations1 | Select-Object -ExpandProperty InstallLocation
        $InstallLocations2 = $InstallLocations2 | Select-Object -ExpandProperty InstallLocation
        Foreach ($InsLoc in $InstallLocations1) {
            if (Test-Path -Path "$Insloc\$path") {
                $Path = "$Insloc\$path"
                $Found = $true
                break
            }
        }
        if (! $found) {
            $Result = $env:Path.split(';').where( { Test-Path -Path "$_\$Path" }, 'first') 
            if ($Result.count -eq 1) { $Found = $true }
        }

        # Processing remaining install location (less probable outcome)
        if (! $found) {
            Foreach ($InsLoc in $InstallLocations2) {
                if (Test-Path -Path "$Insloc\$path") {
                    $Path = "$Insloc\$path"
                    $Found = $true
                    exit for
                }
            }
        }

        if (!$found) {
            Write-Error -Message "The path $Path does not exist"
            return 
        }

    }


    if ($PSBoundParameters.ContainsKey('Name') -eq $false) {
        $Name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    }

    $TempFolderName = "tmp$((48..57 + 97..122| get-random -Count 4 |% {[char][byte]$_}) -join '')"
    $TempFolderPath = "$env:temp\$TempFolderName"
    $ShortcutPath = "$TempFolderPath\$Name.lnk"
    [Void](New-Item -ItemType Directory -Path $TempfolderPath)


    if ($Path.EndsWith(".lnk")) {
        Copy-Item -Path $Path -Destination $ShortcutPath
        $obj = New-Object -ComObject WScript.Shell 
        $link = $obj.CreateShortcut($ShortcutPath) 
    }
    else {
        $obj = New-Object -ComObject WScript.Shell 
        $link = $obj.CreateShortcut($ShortcutPath) 
        $link.TargetPath = $Path
    }

    switch ($WindowStyle) {
        'Minimized' { $WindowstyleID = 7 }
        'Maximized' { $WindowstyleID = 3 }
        'Normal' { $WindowstyleID = 1 }
    }

    $link.Arguments = $Arguments
    $Link.Description = $Description
    if ($PSBoundParameters.ContainsKey('IconLocation')) { $link.IconLocation = $IconLocation }
    $link.Hotkey = "$Hotkey"
    $link.WindowStyle = $WindowstyleID
    if ($PSBoundParameters.ContainsKey('WorkingDirectory')) { $link.WorkingDirectory = $WorkingDirectory }
    if ($PSBoundParameters.ContainsKey('RelativePath')) { $link.RelativePath = $RelativePath }
    $link.Save()

    if ($RunAsAdmin) {
        $bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
        $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
        [System.IO.File]::WriteAllBytes($ShortcutPath, $bytes)
    }

    $Shell = New-Object -ComObject "Shell.Application"
    $Folder = $Shell.Namespace((Get-Item $ShortcutPath).DirectoryName)
    $Item = $Folder.ParseName((Get-Item $ShortcutPath).Name)
    $Item.InvokeVerb("pin")

    Remove-Item -LiteralPath  "HKCU:Software\Classes\*\shell\pin\" -Recurse   
    Remove-item -path $ShortcutPath
    Remove-Item -Path $TempFolderPath 
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$shell)
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$obj)
}

<#
ピン留め別の方法
#>
function PinnedItem {
    param (
        [parameter(Mandatory=$True, HelpMessage="Target item to pin")]
        [ValidateNotNullOrEmpty()]
        [string] $Target
    )

    Write-Host $Target
    if (!(Test-Path $Target)) {
        Write-Warning "$Target does not exist"
        break
    }

    $KeyPath1  = "HKCU:\SOFTWARE\Classes"
    $KeyPath2  = "*"
    $KeyPath3  = "shell"
    $KeyPath4  = "pin"
    $ValueName = "ExplorerCommandHandler"
    $ValueData = (Get-ItemProperty("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.taskbarpin")).ExplorerCommandHandler
    Write-Host $ValueData

    $Key2 = (Get-Item $KeyPath1).OpenSubKey($KeyPath2, $true)
    $Key3 = $Key2.CreateSubKey($KeyPath3, $true)
    $Key4 = $Key3.CreateSubKey($KeyPath4, $true)
    $Key4.SetValue($ValueName, $ValueData)

    $Shell = New-Object -ComObject "Shell.Application"
    $Folder = $Shell.Namespace((Get-Item $Target).DirectoryName)
    $Item = $Folder.ParseName((Get-Item $Target).Name)
    $Item.InvokeVerb("pin")

#    foreach ($v in $Item.Verbs()) {
#        Write-Host $v.Name
#    }
#    $Verb = $Item.Verbs() | ? {($_.Name -match "^&pin")}
#    if ($Verb) {
#        Write-Host "pin to task bar"
#        $Verb.DoIt()
#    }
#    else {
#        Write-Host "Verb is null."
#    }

    $Key3.DeleteSubKey($KeyPath4)
    if ($Key3.SubKeyCount -eq 0 -and $Key3.ValueCount -eq 0) {
        $Key2.DeleteSubKey($KeyPath3)
    }
}


<#
ショートカットをスタートメニューにピン止めする
#>
function PinToStartMenue {
    param(
        [string]$FileFullPath
    )

    if( Test-Path $FileFullPath ) {
        $PathName = Split-Path $FileFullPath -Parent
        $FileNmae = Split-Path $FileFullPath -Leaf

        $Shell = New-Object -ComObject "Shell.Application"
        $TergetFolder = $Shell.Namespace( $PathName )
        Write-Host $TergetFolder.title
        $TergetItem = $TergetFolder.ParseName( $FileNmae )
        if ($TergetItem.IsLink) {
            foreach ($v in $TergetItem.Verbs())
            {
                Write-Host $v.Name
            }

            $Verb = $TergetItem.Verbs() | ? {($_.Name -match "^タスク バーにピン留めする") -or ($_.Name -match "^Pin to Tas&kbar")}
            if ($Verb) {
                $Verb.DoIt()
            }
            else {
                Write-Host "Verb is null."
            }
        }
    }
}


<#
パブリックデスクトップへショートカットを作る
#>
function CreateShortcutToPublicDesktop {
    param(
        [string] $TargetFile,
        [string] $ShortcutPath,
        [string] $ShortcutName
    )

    $ShortcutFile = Join-Path $ShortcutPath $ShortcutName

    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.IconLocation = $TargetFile
    $Shortcut.Save()
    return $ShortcutFile
}

# 対象のアプリケーションパス
$TargetFile = "C:\Program Files\Internet Explorer\iexplore.exe"
#$TargetFile = "C:\Program Files\Mozilla Firefox\firefox.exe"
#$TargetFile = "C:\Windows\notepad.exe"

# ショートカット先のパス
$ShortcutDesk = "C:\Users\Public\Desktop\"
$ShortcutTask = "{0}\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\" -f $env:APPDATA
Write-Host $ShortcutTask

# ショートカットファイル名
$ShortcutName = "InternetExplore.lnk"
#$ShortcutName = "Firefox.lnk"
#$ShortcutName = "memo.lnk"

# デスクトップにショートカット作成
#$pinpath = CreateShortcutToPublicDesktop -TargetFile $TargetFile -ShortcutPath $ShortcutDesk -ShortcutName $ShortcutName

# タスクバーにピン留
#$pinpath = CreateShortcutToPublicDesktop -TargetFile $TargetFile -ShortcutPath $ShortcutTask -ShortcutName $ShortcutName
#PinToStartMenue -FileFullPath $pinpath
#PinnedItem -Target $pinpath
#New-PinnedItem -Path 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' -Arguments '--proxy-server=192.168.1.2:8080'
New-PinnedItem -Path $TargetFile
