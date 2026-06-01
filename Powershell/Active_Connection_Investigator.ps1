Get-NetTcpConnection -State Established | Select-Object LocalPort, RemoteAddress, RemotePort, @{
Name = "ProcessName"
Expression = { 
    (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName
}
}, @{
    Name = "PID"
    Expression = { $_.OwningProcess }
}
Write-Host "Scan complete."