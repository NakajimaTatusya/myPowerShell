
[CmdletBinding()]
param (
    [string]$FileName,
    [ValidateSet(0, 1)]
    [int]$ops
)

begin {

}

process {
    $StorageURL = "https://hogehoge.blob.core.windows.net/foooo/"
    $SASToken = ""
    
    if ($ops -eq 1) {
        $blobUploadParams = @{
            URI = "{0}/{1}?{2}" -f $StorageURL, $FileName, $SASToken
            Method = "PUT"
            Headers = @{
                'x-ms-blob-type' = "BlockBlob"
                'x-ms-blob-content-disposition' = "attachment; filename=`"{0}`"" -f $FileName
                'x-ms-meta-m1' = 'v1'
                'x-ms-meta-m2' = 'v2'
            }
            Body = $Content
            Infile = $FileToUpload
        }
    }
    else {
        $blobUploadParams = @{
            URI = "{0}?restype=container&comp=list" -f $StorageURL
            Method = "GET"
            Headers = @{
                'Authorization' = $SASToken
                'Content-Type' = 'application/json'
            }
            Body = $Content
            Infile = $FileToUpload
        }
    }
    $response = Invoke-WebRequest -Method $blobUploadParams["Method"] -Uri $blobUploadParams["URI"] -Headers $blobUploadParams["Headers"]
    Write-host ("{0} : {1}" -f $response.StatusCode, $response.content)
}

end {

}
