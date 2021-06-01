Function Get-SoftwareInstallPath {
    [OutputType('System.Software.Inventory')]
    [Cmdletbinding()] 

    Param( 
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)] 
        [String[]]$Computername = $env:COMPUTERNAME,
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)] 
        [String]$Findname = ""
    )         

    Begin {
    }

    Process {     
        ForEach ($Computer in  $Computername) { 
            If (Test-Connection -ComputerName  $Computer -Count  1 -Quiet) {
                $Paths = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
                ForEach ($Path in $Paths) { 
                    Write-Verbose  "Checking Path: $Path"
                    #  Create an instance of the Registry Object and open the HKLM base key 
                    Try { 
                        $reg = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', $Computer, 'Registry64') 
                    }
                    Catch { 
                        Write-Error $_ 
                        Continue 
                    } 

                    Try {
                        $regkey = $reg.OpenSubKey($Path)
                        $subkeys = $regkey.GetSubKeyNames()
                        $ObjectArray = @()
                        ForEach ($key in $subkeys) {
                            Write-Verbose "Key: $Key"
                            $thisKey = $Path + "\\" + $key
                            Try {
                                $thisSubKey = $reg.OpenSubKey($thisKey)
                                $DisplayName = $thisSubKey.getValue("DisplayName")
                                if ($DisplayName -notmatch $Findname) {
                                    Continue
                                }
                                
                                If ($DisplayName -AND $DisplayName -notmatch '^Update  for|rollup|^Security Update|^Service Pack|^HotFix') {
                                    $Date = $thisSubKey.GetValue('InstallDate')
                                    If ($Date) {
                                        Try {
                                            # ParseExact は、第2引数がロケールに影響されるので注意!!
                                            $Date = $Date.replace("/", "")
                                            $Date = [datetime]::ParseExact($Date, "yyyyMMdd", $Null)
                                        }
                                        Catch {
                                            Write-Warning "$($Computer): $_ <$($Date)>"
                                            $Date = $Null
                                        }
                                    }

                                    $Publisher = Try {
                                        $thisSubKey.GetValue('Publisher').Trim()
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('Publisher')
                                    }

                                    $Version = Try {
                                        $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32, 0)))
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('DisplayVersion')
                                    }

                                    $UninstallString = Try {
                                        $thisSubKey.GetValue('UninstallString').Trim()
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('UninstallString')
                                    }

                                    $InstallLocation = Try {
                                        $thisSubKey.GetValue('InstallLocation').Trim()
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('InstallLocation')
                                    }

                                    $InstallSource = Try {
                                        $thisSubKey.GetValue('InstallSource').Trim()
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('InstallSource')
                                    }

                                    $HelpLink = Try {
                                        $thisSubKey.GetValue('HelpLink').Trim()
                                    } 
                                    Catch {
                                        $thisSubKey.GetValue('HelpLink')
                                    }

                                    $Object = [PSCustomObject]@{
                                        'Computername'    = $Computer
                                        'DisplayName'     = $DisplayName
                                        'Version'         = $Version
                                        'InstallDate'     = $Date
                                        'Publisher'       = $Publisher
                                        'UninstallString' = $UninstallString
                                        'InstallLocation' = $InstallLocation
                                        'InstallSource'   = $InstallSource
                                        'HelpLink'        = $thisSubKey.GetValue('HelpLink')
                                        'EstimatedSizeMB' = [decimal]([math]::Round(($thisSubKey.GetValue('EstimatedSize') * 1024) / 1MB, 2))
                                    }
                                    $ObjectArray += $Object
                                }
                            }
                            Catch {
                                Write-Warning "$Key : $_"
                            }   
                        }
                    }
                    Catch {}   
                    $reg.Close() 
                }                  
                return $ObjectArray
            }
            Else {
                Write-Error  "$($Computer): リモートシステムに到達できませんでした。"
            }
        } 
    } 
}

#Get-Software -Computername $env:COMPUTERNAME | Where-Object DisplayName -Like "Microsoft Edge"
Get-SoftwareInstallPath -Computername $env:COMPUTERNAME -Findname "Microsoft Edge"
