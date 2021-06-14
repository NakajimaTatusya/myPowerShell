# Import config
. .\get-folderfile-information-config.ps1

<#
 ファイル総数、ファイル総サイズを算出する
 parameters:
    Path: 対象のディレクトリフルパス
    Scale: 容量の単位（KB、MB、GB）
#>
function Get-FileCountAndSize {
    [CmdletBinding()]
    param
    (
        [parameter(
            position = 0,
            mandatory = 1,
            valuefrompipeline = 1,
            valuefrompipelinebypropertyname = 1)]
        [string[]]
        $Path = $null,

        [parameter(
            position = 1,
            mandatory = 0,
            valuefrompipelinebypropertyname = 1)]
        [validateSet("KB", "MB", "GB")]
        [string]
        $Scale = "KB"
    )
    process {
        [decimal] $totalFileCount = 0
        [decimal] $totalFileSize = 0
        $FileInfoObj = @{}
        $Path `
        | %{
            if (Test-Path $_) {
                $FileInfoObj = New-Object PSObject | Select-Object FullPath,TotalFolderCount,TotalFileCount,TotalSize
                $FileInfoObj.FullPath = $_
                Get-ChildItem -Path $_ -File -Recurse | ForEach-Object {
                    $totalFileSize += $_.Length
                    $totalFileCount++
                }
                $FileInfoObj.TotalFileCount = $totalFileCount
                $totalSize = [decimal]("{0:N4}" -f ($totalFileSize / "1{0}" -f $scale))
                $FileInfoObj.TotalSize = "{0}{1}" -f $totalSize,$scale
                $FileInfoObj.TotalFolderCount = (Get-ChildItem -Path $_ -Directory -Recurse | Measure-Object).Count
            }
        }
        return $FileInfoObj
    }
}

$Informations = @()
$names = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])
foreach($name in $names)
{
    if($path = [Environment]::GetFolderPath($name)){
        if ($TargetAlias.Contains($name)) {
            $Informations += Get-FileCountAndSize -Path $path -Scale MB
        }
    }
}
if ($TargetAlias.Contains("Download")) {
    $Informations += Get-FileCountAndSize -Path (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path -Scale MB
}
foreach ($path in $IndividualTarget) {
    $Informations += Get-FileCountAndSize -Path $path -Scale MB
}

# 表を出力
$Informations | ForEach-Object {[PSCustomObject]$_} `
| Format-Table `
@{label='TargetDirectory';expression={$_.FullPath};width=60;alignment='left';}, `
@{label='TotalFolderCount';expression={$_.TotalFolderCount};width=20;alignment='left';}, `
@{label='TotalFileCount';expression={$_.TotalFileCount};width=20;alignment='left';}, `
@{label='TotalFileSize';expression={$_.TotalSize};width=20;alignment='left';}

# Json を出力
ConvertTo-Json $Informations

$Informations | Export-Csv -Path ce_folder_file_info.csv -Encoding Default -NoTypeInformation

<#
1次元のオブジェクト配列はJsonにすると、配列ではなくなるので、2番目のConvertTo-Jsonのような使い方をすること
$arrays = @(@{a=1;b=2;})
$arrays | ConvertTo-Json
ConvertTo-Json $arrays
#>
