<#
ver.202107060935
discription: pingを実行し、ARPテーブルを作成し、ホスト名、IPアドレス、マックアドレスをCSVファイルに出力する。
args:
    arg1: 24ビットのIPv4部分
    arg2: 開始IPv4ホスト部
    arg3: 終了IPv4ホスト部
author: tatsuya.nakajima@jp.ricoh.com
#>
[CmdletBinding()]
Param (
    [string]$Network = '10.22.129',
    [int]$IPStart = '1',
    [int]$IPEnd = '255',
    [switch]$PingStatusErrorOutput
)

begin {
    # 不要なら下記2行コメントアウト
    Write-Output "CLEAR ARP TABLE (Request administrator privileges)."
    Start-Process "cmd" "/c arp -d *" -Verb runas -WindowStyle Hidden

    # Ping Status hashtable初期化
    $win32_pingStatus = @{}
    $win32_pingStatus.Add(0, "Success")
    $win32_pingStatus.Add(11001, "Buffer Too Small")
    $win32_pingStatus.Add(11002, "Destination Net Unreachable")
    $win32_pingStatus.Add(11003, "Destination Host Unreachable")
    $win32_pingStatus.Add(11004, "Destination Protocol Unreachable")
    $win32_pingStatus.Add(11005, "Destination Port Unreachable")
    $win32_pingStatus.Add(11006, "No Resources")
    $win32_pingStatus.Add(11007, "Bad Option")
    $win32_pingStatus.Add(11008, "Hardware Error")
    $win32_pingStatus.Add(11009, "Packet Too Big")
    $win32_pingStatus.Add(11010, "Request Timed Out")
    $win32_pingStatus.Add(11011, "Bad Request")
    $win32_pingStatus.Add(11012, "Bad Route")
    $win32_pingStatus.Add(11013, "TimeToLive Expired Transit")
    $win32_pingStatus.Add(11014, "TimeToLive Expired Reassembly")
    $win32_pingStatus.Add(11015, "Parameter Problem")
    $win32_pingStatus.Add(11016, "Source Quench")
    $win32_pingStatus.Add(11017, "Option Too Big")
    $win32_pingStatus.Add(11018, "Bad Destination")
    $win32_pingStatus.Add(11032, "Negotiating IPSEC")
    $win32_pingStatus.Add(11050, "General Failure")

    # 結果格納変数初期化
    $outArray = @()
}

process {
    Write-Output "SEARCHING MAC ADDRESS."
    ForEach ($IP in ($IPStart..$IPEnd))
    {
        [System.Net.IPAddress]$ip4 = ("{0}.{1}" -f $Network, $IP)

        Try {
            Write-Verbose 'Ping start ...'
            Write-Verbose ($ip4.IPAddressToString)
            $Ping = Get-WMIObject Win32_PingStatus -Filter "Address = '$Network.$IP' AND ResolveAddressNames = TRUE" -ErrorAction Stop
            Write-Verbose ("Ping Status Code is {0}:{1}" -f $Ping.StatusCode, $win32_pingStatus[$Ping.StatusCode -as [int]])
        }
        Catch {
            Write-Output $_.Exception.Message
            Continue
        }

        try {
            Write-Verbose 'get HOSTNAME ...'
            $hostname = ([system.net.dns]::GetHostByAddress($ip4.IPAddressToString)).hostname
            Write-Verbose $hostname
        }
        catch {
            $hostname = 'The host name was not retrieved'
            Write-Verbose $_.Exception.Message
        }

        if ($Ping.StatusCode -eq 0)
        {
            Write-Verbose 'Success Ping.'
            $outArray += [pscustomobject] @{
                HOSTNAME=$hostname;
                IPv4_ADDRESS=$ip4.IPAddressToString;
                MACAddress="";
                PingStatusCode=$Ping.StatusCode;
                PingStatusMessage=$win32_pingStatus[$Ping.StatusCode -as [int]]
            }
        }
        else
        {
            if ($PingStatusErrorOutput)
            {
                Write-Verbose 'Failed Ping.'
                $outArray += [pscustomobject] @{
                    HOSTNAME="";
                    IPv4_ADDRESS=$ip4.IPAddressToString;
                    MACAddress="";
                    PingStatusCode=$Ping.StatusCode;
                    PingStatusMessage=$win32_pingStatus[$Ping.StatusCode -as [int]]
                }
            }
        }
    }
}

end {
    Write-Output "OUTPUT MAC ADDRESS."
    $arp = cmd /c "arp -a"
    ForEach ($line in $arp) {
        ForEach ($IP in $outArray)
        {
            if ($line -match $IP.IPv4_ADDRESS) {
                $line -match "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})"
                $IP.MACAddress = $Matches[0]
            }
        }
    }
    $filename = "{0}-IPMAC.csv" -f (Get-Date).ToString('yyyyMMddHHmmss')
    $outArray | Export-Csv -Path $filename
}
