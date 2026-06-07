Get-WinEvent -FilterHashtable @{
    LogName = "Security"
    Id = 4624
    StartTime = (Get-Date).AddHours(-24)
} |
Where-Object {
    $_.Properties[8].Value -eq 10
} |
ForEach-Object {
    [PSCustomObject]@{
        User   = $_.Properties[5].Value
        Time   = $_.TimeCreated
        Src_IP = $_.Properties[18].Value
    }
}