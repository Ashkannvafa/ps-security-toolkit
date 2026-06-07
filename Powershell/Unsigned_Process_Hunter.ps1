$excludedThumbprints = @(
    "FACDE3D80E99AFCC15E08AC5A69BD22785287F79",
    "800B886943D4073408889567F6F362D7575D",
    "3300000082544378A293532231455500A082D42C",
    "A43416E83C1FAE1B489470E768E766B2FE0D",
    "7F8877D39B62A82C4B80D360146F9E980A5F",
    "2A03E3737384627396D5D0520894D761C26A"
)
Get-Process | 
Where-Object {
    $path = $_.Path
    if (-not $path -or -not (Test-Path $path)) {
        return $true
    }
    $signature = Get-AuthenticodeSignature -FilePath $path -ErrorAction SilentlyContinue
    if (-not $signature) {
        return $true
    }
    if ($path -match "AppData|Temp|Downloads") {
        return $true
    }
    $thumbprint = $signature.SignerCertificate.Thumbprint
    return $thumbprint -notin $excludedThumbprints
} | 
ForEach-Object {
    $path = $_.Path
    $signatureStatus = if ($path -and (Test-Path $path)) {
        (Get-AuthenticodeSignature -FilePath $path).Status
    } else {
        "N/A"
    }

    [PSCustomObject]@{
        Process    = $_.ProcessName
        PID        = $_.Id
        Path       = $path
        Signature  = $signatureStatus
    }
}