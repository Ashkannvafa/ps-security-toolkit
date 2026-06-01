$Processes = Get-Process | Select-Object Name, Id, Path | Where-Object { $_.Path -match "AppData|Temp|Downloads|Public" }

if ($Processes) {
    $Processes | Format-Table
} else {
    Write-Host "No suspicious processes found"
}