# 管理者権限で実行されているか？確認する。
function Test-Admin
{
     (
        [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::
        GetCurrent()
     ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 指定されたスクリプトを管理者権限で実行する
function Start-ScriptAsAdmin
{
    param(
        [string]
        $ScriptPath,
        [object[]]
        $ArgumentList
    )

    if(!(Test-Admin))
    {
        $list = @($ScriptPath)
        if($null -ne $ArgumentList)
        {
             $list += @($ArgumentList)
        }
        Start-Process powershell -ArgumentList $list -Verb RunAs -Wait
    }
    else {
        Write-Host "管理者権限では起動していない"
    }
}

# 与えられたパスのPowerShellスクリプトを管理者権限で実行
Start-ScriptAsAdmin -ScriptPath "TestRunAsAdministrator.ps1"
