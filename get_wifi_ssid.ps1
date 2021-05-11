# netsh コマンドで無線ランの情報を取得
netsh wlan  show network  mode=bssid 

# 取得した情報を変数へ
$WiFi = (netsh wlan show network  mode=bssid |  Select-Object -Skip  3).Trim()  | Out-String

# 正規表現のパターンを作成
$RegEx = @'
  (?x)
  SSID\s\d+\s:\s(?<SSID>[a-z0-9\-\*\.&_]+)\r\n
  Network\stype\s+:\s(?<NetworkType>\w+)\r\n
  Authentication\s+:\s(?<Authentication>[a-z0-9\-_]+)\r\n
  Encryption\s+:\s(?<Encryption>\w+)\r\n
  BSSID\s1\s+:\s(?<BSSID>(?:\w+:){5}\w+)\r\n
  Signal\s+:\s(?<Signal>\d{1,2})%\r\n
  Radio\stype\s+:\s(?<Radio>[a-z0-9\.]+)\r\n
  Channel\s+:\s(?<Channel>\w+)\r\n
'@ 

$Networks = $WiFi -split  "\r\s+\n"

$WiFiNetworks = $Networks | ForEach-Object {
    If ($_ -match $RegEx) {
        [pscustomobject]@{
            SSID =  $Matches.SSID
            NetworkType = $Matches.NetworkType
            AuthenticationType = $Matches.Authentication
            Encryption =  $Matches.Encryption
            BSSID1 =  $Matches.BSSID
            SignalPercentage = [int]$Matches.Signal
            RadioType =  $Matches.Radio
            Channel =  $Matches.Channel
        }
    }
}
$WiFiNetworks | Sort-Object SignalPercentage -Descending 


###
#
# Wifiの情報取得
# 日本語環境だと、Regexのパターンが翻訳されたものになっているので
# マッチしないことがある。
# 
#
###
Function Get-WifiNetwork
{
    $RegEx = @'
(?x)
SSID\s\d+\s:\s(?<SSID>[a-z0-9\-\*\.&_]+)\r\n
Network\stype\s+:\s(?<NetworkType>\w+)\r\n
Authentication\s+:\s(?<Authentication>[a-z0-9\-_]+)\r\n
Encryption\s+:\s(?<Encryption>\w+)\r\n
BSSID\s1\s+:\s(?<BSSID>(?:\w+:){5}\w+)\r\n
Signal\s+:\s(?<Signal>\d{1,2})%\r\n
Radio\stype\s+:\s(?<Radio>[a-z0-9\.]+)\r\n
Channel\s+:\s(?<Channel>\w+)\r\n
'@
    $RegExJP = @'
(?x)
SSID\s\d+\s:\s(?<SSID>[a-z0-9\-\*\.&_]+)\r\n
ネットワークの種類\s+:\s(?<NetworkType>\w+)\r\n
認証\s+:\s(?<Authentication>[a-z0-9\-_]+)\r\n
暗号化\s+:\s(?<Encryption>\w+)\r\n
BSSID\s1\s+:\s(?<BSSID>(?:\w+:){5}\w+)\r\n
シグナル\s+:\s(?<Signal>\d{1,2})%\r\n
無線タイプ\s+:\s(?<Radio>[a-z0-9\.]+)\r\n
チャネル\s+:\s(?<Channel>\w+)\r\n
'@

    $WiFi = (netsh wlan show  network mode=bssid  | Select-Object  -Skip 3).Trim() | Out-String
    $WiFi

    $Networks  = $WiFi  -split "\r\s+\n"

    $Networks | ForEach-Object {
        If ($_ -match  $RegEx) {
            [pscustomobject]@{
                SSID =  $Matches.SSID
                NetworkType = $Matches.NetworkType
                AuthenticationType = $Matches.Authentication
                Encryption = $Matches.Encryption
                BSSID1 =  $Matches.BSSID
                SignalPercentage = [int]$Matches.Signal
                RadioType = $Matches.Radio
                Channel = $Matches.Channel
            }
        }
        If ($_ -match  $RegExJP) {
            [pscustomobject]@{
                SSID =  $Matches.SSID
                NetworkType = $Matches.NetworkType
                AuthenticationType = $Matches.Authentication
                Encryption = $Matches.Encryption
                BSSID1 =  $Matches.BSSID
                SignalPercentage = [int]$Matches.Signal
                RadioType = $Matches.Radio
                Channel = $Matches.Channel
            }
        }
    }
}

Get-WifiNetwork
