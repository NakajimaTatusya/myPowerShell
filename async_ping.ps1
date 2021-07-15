<#
Ping処理を非同期で行う。早い

参考にしたコード
https://tech.guitarrapc.com/entry/2013/10/29/100946
https://qiita.com/Kill_In_Sun/items/b779c57e899521ea6817#
https://junjun777.hatenablog.com/entry/20141128/powershell_async_task
https://learn-powershell.net/2016/04/22/speedy-ping-using-powershell/

ランスペースのドキュメント
https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.runspaces.runspacefactory?view=powershellsdk-7.0.0
Ping Class Document
https://docs.microsoft.com/ja-jp/dotnet/api/system.net.networkinformation.ping?view=net-5.0
IPStatus 列挙型
| return_value | status_code | description |
| :--- | ---: | :--- |
| BadDestination | 11018 | 送信先の IP アドレスが ICMP エコー要求を受信できないため、または IP データグラムの終点アドレス フィールドに指定できない値であるために、ICMP エコー要求は失敗しました。 たとえば、Send を呼び出し、IP アドレス "000.0.0.0" を指定すると、このステータスが返されます。 |
| BadHeader | 11042 | ヘッダーが無効なため、ICMP エコー要求は失敗しました。 |
| BadOption | 11007 | 無効なオプションが含まれているため、ICMP エコー要求は失敗しました。 |
| BadRoute | 11012 | 送信元コンピューターと送信先コンピューターの間に有効な経路がないため、ICMP エコー要求は失敗しました。 |
| DestinationHostUnreachable | 11003 | 送信先コンピューターに到達できないため、ICMP エコー要求は失敗しました。 |
| DestinationNetworkUnreachable | 11002 | 送信先コンピューターが含まれるネットワークに到達できないため、ICMP エコー要求は失敗しました。 |
| DestinationPortUnreachable | 11005 | 送信先コンピューターのポートが利用できないため、ICMP エコー要求は失敗しました。 |
| DestinationProhibited | 11004 | 送信先コンピューターとの通信が管理上禁止されているため、ICMPv エコー要求は失敗しました。 この値は IPv6 にのみ適用されます。 |
| DestinationProtocolUnreachable | 11004 | ICMP エコー メッセージに指定された送信先コンピューターが、パケットのプロトコルをサポートしておらず到達できないため、ICMP エコー要求は失敗しました。 この値は IPv4 にのみ適用されます。 この値は、管理者によって通信が禁止されていることが IETF RFC 1812 に記述されています。 |
| DestinationScopeMismatch | 11045 | ICMP エコー メッセージに指定された送信元アドレスと終点アドレスが同じスコープにないため、ICMP エコー要求は失敗しました。 これは通常、送信元アドレスのスコープ外にあるインターフェイスを使用してパケットを転送するルーターが原因で発生します。 あるアドレスがネットワーク上で有効な範囲は、アドレス スコープ (リンクローカル、サイトローカル、グローバル スコープ) によって決まります。 |
| DestinationUnreachable | 11040 | ICMP エコー メッセージに指定された送信先コンピューターに到達できないため、ICMP エコー要求は失敗しました。問題の詳細な原因は不明です。 |
| HardwareError | 11008 | ハードウェア エラーのため、ICMP エコー要求は失敗しました。 |
| IcmpError | 11044 | ICMP プロトコル エラーのため、ICMP エコー要求は失敗しました。 |
| NoResources | 11006 | ネットワーク リソースの不足のため、ICMP エコー要求は失敗しました。 |
| PacketTooBig | 11009 | 要求を格納しているパケットが、送信元と送信先の間にあるノード (ルーターまたはゲートウェイ) の MTU (Maximum Transmission Unit) よりも大きいため、ICMP エコー要求は失敗しました。 MTU は、送信できるパケットの最大サイズを定義します。 |
| ParameterProblem | 11015 | パケット ヘッダーの処理中にノード (ルーターまたはゲートウェイ) で問題が発生したため、ICMP エコー要求は失敗しました。 たとえば、ヘッダーに無効なフィールド データや認識できないオプションが含まれている場合、このステータスになります。 |
| SourceQuench | 11016 | パケットが破棄されたため、ICMP エコー要求は失敗しました。 これは、送信元コンピューターの出力キューに十分なストレージ領域がない場合や、送信先に到達するパケットの量が多すぎて処理しきれない場合に発生します。 |
| Success | 0 | ICMP エコー要求は成功しました。ICMP エコー応答が受信されました。 このステータス コードを取得した場合、他の PingReply プロパティに有効なデータが格納されています。 |
| TimedOut | 11010 | 割り当てられた時間内に ICMP エコー応答が受信されませんでした。 各応答に割り当てられる既定の時間は 5 秒です。 この値は、timeout パラメーターを受け取る Send メソッドまたは SendAsync メソッドを使用して変更できます。 |
| TimeExceeded | 11041 | 有効期間 (TTL: time-to-live) の値が 0 に達し、転送を行うノード (ルーターまたはゲートウェイ) でパケットが破棄されたため、ICMP エコー要求は失敗しました。 |
| TtlExpired | 11013 | 有効期間 (TTL: time-to-live) の値が 0 に達し、転送を行うノード (ルーターまたはゲートウェイ) でパケットが破棄されたため、ICMP エコー要求は失敗しました。 |
| TtlReassemblyTimeExceeded | 11014 | 伝送用に分割されたパケットのフラグメントが、再アセンブルの割り当て時間内にすべて受信されなかったため、ICMP エコー要求は失敗しました。 RFC 2460 では、すべてのパケットのフラグメントは、60 秒以内に受信される必要があると指定されています。 |
| Unknown | -1 | 不明な理由のために ICMP エコー要求は失敗しました。 |
| UnrecognizedNextHeader | 11043 | 認識される値が Next Header フィールドに含まれていないため、ICMP エコー要求は失敗しました。 Next Header フィールドは、拡張ヘッダーの種類 (存在する場合) や、TCP か UDP などの IP 層より上のプロトコルを示します。 |

IPv4からホスト名
https://docs.microsoft.com/en-us/dotnet/api/system.net.dns.gethostentryasync?view=net-5.0

#>
[CmdletBinding()]
param (
    [string]$Network = '192.168.1',
    [int]$IPStart = '100',
    [int]$IPEnd = '110',
    [switch]$PingStatusErrorOutput
)

begin {
    # Debug出力有効
    $DebugPreference = "Continue"
    $retval = @()
}

process {
    try {
        Write-Debug "ランスペースを作成する"
        $Private:_sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        $Private:_minPoolSize = $_maxPoolSize = 10
        $Private:_runspacePool = [runspacefactory]::CreateRunspacePool($Private:_minPoolSize, $_maxPoolSize, $Private:_sessionState, $Host)
        $Private:_runspacePool.ApartmentState = "STA"
        $Private:_runspacePool.Open()

        ForEach ($IP in ($IPStart..$IPEnd)) {
            $command = {
                [CmdletBinding()]
                param (
                    [Parameter(Mandatory)]
                    [System.Net.IPAddress]
                    $Ipv4Address
                )

                $private:originalErrorActionPreference = $ErrorActionPreference
                $ErrorActionPreference = "Continue"
                $DebugPreference = "Continue"

                try {
                    # Ping用のアセンブリを追加
                    Add-Type -AssemblyName System.Net.NetworkInformation
                    Add-Type -AssemblyName System.Net.Dns
                }
                catch { }

                Write-Debug ('PING開始:' + $Ipv4Address.IPAddressToString)
                # Pingオブジェクト作成
                $pingObj = New-Object -TypeName System.Net.NetworkInformation.Ping
                $Task = $pingObj.SendPingAsync($Ipv4Address.IPAddressToString)
                $Task.Wait()
                $Task
                $pingObj.Dispose()
                $ErrorActionPreference = $originalErrorActionPreference
            }

            # Main Invokation
            Write-Debug "非同期呼び出しを開始します"
            [System.Net.IPAddress]$IPv4 = ("{0}.{1}" -f $Network, $IP)
            $private:powershell = [PowerShell]::Create().AddScript($command).AddArgument($IPv4)
            $powershell.RunspacePool = $_runspacePool
            [array]$private:RunspaceCollection += New-Object -TypeName PSObject -Property @{
                Runspace = $powershell.BeginInvoke();
                powershell = $powershell
            }
        }

        # プロセス結果の確認
        Write-Debug "非同期実行が行われたことを確認します"
        while (($runspaceCollection.RunSpace | Sort-Object IsCompleted -Unique).IsCompleted -ne $true)
        {
            Start-Sleep -Milliseconds 5
        }

        # プロセスの結果とPowerShellセッションの終了
        Write-Debug "プロセス結果を取得する"
        foreach ($runspace in $runspaceCollection)
        {
            # 非同期コマンドの結果を取得する
            $private:task = $runspace.powershell.EndInvoke($runspace.Runspace)

            # 結果を表示
            if ($task.IsCompleted)
            {
                # 結果を得る
                $private:result = $task.Result
                # ソートされたハッシュテーブルを作成してオブジェクトを作成する
                $private:obj = [ordered]@{
                    address = $result.Address   # エコー応答のIPv4アドレスだから注意!
                    status = $result.Status
                    roundtriptime = $result.RoundtripTime
                    options = $result.Options
                    buffer = $result.Buffer
                }
        
                # 出力するPSObjectを作成します
                $private:output = New-Object -TypeName PSObject -Property $obj

                # 結果をホストに返します
                $retval += $output
            }

            # パイプラインを破棄する
            $runspace.powershell.Dispose()
        }
    }
    catch {
        Write-Debug $_.Exception.Message
    }
    finally {
        # ランスペースを破棄する
        $_runspacePool.Dispose()
    }
}

End {
    try {
        Add-Type -AssemblyName System.Net
    }
    catch { }
    foreach ($element in $retval) {
        Write-Output $element.address.IPAddressToString
        # IP からホスト名を取得するのも時間かかるから非同期にしたほうがいい
        if ($element.status -eq "Success") {
            $hostname = ""
            try {
                [System.Net.IPHostEntry]$he = [System.Net.Dns]::GetHostEntry($element.address)
                $hostname = $he.HostName
            }
            catch {
                $hostname = $_.Exception.Message
            }
            Write-Output $hostname
        }
    }
}
