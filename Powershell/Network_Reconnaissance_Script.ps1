$subnet = Read-Host "Enter the Subnet"
$results = @()
for ( $i = 1; $i -lt 256; $i++ ) {
    $ip = "$subnet.$i"
    
    if ( Test-Connection -ComputerName $ip -Count 1 -Quiet ) {
        Write-Host "$ip is Alive !" -ForegroundColor Green

        $hostName = "Unknown"

        try {
            $hostName = (Resolve-DnsName $ip -ErrorAction Stop).NameHost
            Write-Host "Hostname : $hostName"
        } catch {
            Write-Host "Hostname Not Found"
        }

        $ports = 22, 80, 443, 3389, 445, 21, 23
        foreach ( $port in $ports ) {
            if ( (Test-NetConnection -ComputerName $ip -Port $port -WarningAction SilentlyContinue).TcpTestSucceeded ) {
                Write-Host "$ip : $port - Open" -ForegroundColor Green

                $results += [PSCustomObject]@{
                    IP = $ip
                    HostName = $hostName
                    Port = $port
                    Status = "Open"
                }
            } else {
                Write-Host "$ip : $port - Not Responding" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "$ip is Dead!" -ForegroundColor Red
        $results += [PSCustomObject]@{
            IP = $ip
            HostName = "N/A"
            Port = "N/A"
            Status = "Dead"
        }
    }
}

Write-Host "`n=== SCAN RESULTS ===" -ForegroundColor Yellow
$results | Format-Table -AutoSize