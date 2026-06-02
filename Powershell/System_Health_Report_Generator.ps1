# CPU USAGE
$CpuUsage = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue, 2)
Write-Host "Cpu Usage : $CpuUsage %"

# MEMORY
$UsedMemory = [math]::Round((Get-Counter '\Memory\Committed Bytes').CounterSamples.CookedValue/ 1GB, 2)
$MemoryUsagePercentage = [math]::Round((Get-Counter '\Memory\% Committed Bytes In Use').CounterSamples.CookedValue, 2)
Write-Host "Memory Usage : $UsedMemory GB, $MemoryUsagePercentage %"

if ( $MemoryUsagePercentage -gt 80 ) {
    Write-Host "Memory is OverWhelmed!" -ForegroundColor Red
}

# DISK SPACE    
$TotalSpace = [math]::Round((Get-CimInstance -ClassName Win32_LogicalDisk).Size / 1GB, 2)
$FreeSpace = [math]::Round((Get-CimInstance -ClassName Win32_LogicalDisk).FreeSpace / 1GB, 2)
$DiskFreePercentage = [math]::Round(($FreeSpace/$TotalSpace) * 100, 2)
Write-Host "Total Disk Space : $TotalSpace GB, Free Disk Space : $FreeSpace GB ($DiskFreePercentage% Free)"

if ( $DiskFreePercentage -lt 10 ) {
    Write-Host "Disk Space is OverWhelmed! (Less than 10% Free)" -ForegroundColor Red
}

# RUNNING CRITICAL SERVICES
Write-Host "`nRUNNING CRITICAL SERVICES : "
Get-Service -ErrorAction SilentlyContinue | 
    Where-Object { $_.Status -eq "Running" } | 
    Where-Object { $_.Name -Match "WinDefend|EventLog|mpssvc" } | 
    Select-Object @{ Name = 'ServiceStatus'; Expression = { $_.Status } }, @{ Name = 'ServiceName'; Expression = { $_.Name } } | Out-String | Write-Host

# TOP 5 PROCESSES BY MEMORY USAGE
Write-Host "TOP 5 PROCESSES BY MEMORY USAGE : "
Get-Process -ErrorAction SilentlyContinue | 
    Sort-Object WS -Descending | 
    Select-Object -First 5 | 
    Select-Object @{ Name = 'Process'; Expression = { $_.ProcessName } } | Out-String | Write-Host