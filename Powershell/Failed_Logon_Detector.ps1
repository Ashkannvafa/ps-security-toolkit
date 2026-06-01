try {
    $result = Get-WinEvent -FilterHashtable @{
        LogName = "Security"
        Id = 4625
        StartTime = (Get-Date).AddHours(-24) 
    } -ErrorAction Stop

    $result | Select-Object TimeCreated, Message

    $failedCount = ($result | Measure-Object).Count

    Write-Host "Total failed logins: $failedCount"

}
catch {
    Write-Host "No events found or access denied"
}
