function Test-SqlConnection {
    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $ErrorActionPreference = 'Stop'

    try {
        $userName = $Credential.UserName
        $password = $Credential.GetNetworkCredential().Password
        $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$userName,$password
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $sqlConnection.Open()
        $true
    } catch {
        $false
    } finally {
        $sqlConnection.Close()
    }
}

Test-SqlConnection -ServerName 'serverhostname' -DatabaseName 'DbName' -Credential (Get-Credential)