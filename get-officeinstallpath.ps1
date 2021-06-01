Function Get-OfficeSoftwareInstallPath {
    <#
    .Synopsis
    Office（Word、Excel、PowerPoint）のインストールパスを取得
    .DESCRIPTION
    .LINK
    https://github.com/OfficeDev/Office-IT-Pro-Deployment-Scripts
    #>
    [CmdletBinding()]
    param(
        [string[]]$ComputerNames = @(".")
    )
    
    begin {
        $HKLM = [UInt32] "0x80000002"
        $officeKeys = 'SOFTWARE\Microsoft\Office',
        'SOFTWARE\Wow6432Node\Microsoft\Office'
    }
    
    process {
        $ComputerName = $env:computername

        $VersionList = New-Object -TypeName System.Collections.ArrayList
        $PathList = New-Object -TypeName System.Collections.ArrayList

        foreach ($computer in $ComputerNames) {
            $regProv = Get-Wmiobject -list "StdRegProv" -namespace root\default -computername $computer
            foreach ($regKey in $officeKeys) {
                $officeVersion = $regProv.EnumKey($HKLM, $regKey)
                foreach ($key in $officeVersion.sNames) {
                    if ($key -match "\d{2}\.\d") {
                        if (!$VersionList.Contains($key)) {
                            $VersionList.Add($key)
                        }
                        $path = join-path $regKey $key
                        $officeItems = $regProv.EnumKey($HKLM, $path)
                        foreach ($itemKey in $officeItems.sNames) {
                            $itemPath = join-path $path $itemKey
                            $installRootPath = join-path $itemPath "InstallRoot"
                            $filePath = $regProv.GetStringValue($HKLM, $installRootPath, "Path").sValue
                            if ($filePath) {
                                if ((!$PathList.Contains($filePath)) -And (Test-Path($filePath))) {
                                    $PathList.Add($filePath)
                                }
                            }
                        }
                    }
                }
            }
        }
        return $PathList
    }
}

$ComputerNames = @($env:COMPUTERNAME)
$OfficeVersions = Get-OfficeSoftwareInstallPath -ComputerNames $ComputerNames
$OfficeVersions | ForEach-Object { if (Test-Path($_)) { Write-Host $_ } }
