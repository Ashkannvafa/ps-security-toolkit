$users = @{}
Get-WinEvent -FilterHashtable @{ LogName = "Security"; Id = 4625; StartTime = (Get-Date).AddHours(-24) } -ErrorAction SilentlyContinue |
ForEach-Object {
    $xml = [xml]$_.ToXml()
    $user = $xml.Event.EventData.Data | Where-Object Name -eq 'TargetUserName' | Select-Object -ExpandProperty '#text'

    if (-not $users.ContainsKey($user)) {
        $users[$user] = [PSCustomObject]@{
            UserName        = $user
            FailedLogon     = 0
            SuccessfulLogon = 0
            CreatedRecently = $false
            AddedToGroup    = @()
        }
    }

    $users[$user].FailedLogon++
}

Get-WinEvent -FilterHashtable @{ LogName = "Security"; Id = 4624; StartTime = (Get-Date).AddHours(-24) } -ErrorAction SilentlyContinue |
ForEach-Object {
    $xml = [xml]$_.ToXml()
    $user = $xml.Event.EventData.Data | Where-Object Name -eq 'TargetUserName' | Select-Object -ExpandProperty '#text'

    if (-not $users.ContainsKey($user)) {
        $users[$user] = [PSCustomObject]@{
            UserName        = $user
            FailedLogon     = 0
            SuccessfulLogon = 0
            CreatedRecently = $false
            AddedToGroup    = @()
        }
    }

    $users[$user].SuccessfulLogon++
}

Get-WinEvent -FilterHashtable @{ LogName = "Security"; Id = 4720; StartTime = (Get-Date).AddHours(-24) } -ErrorAction SilentlyContinue |
ForEach-Object {
    $xml = [xml]$_.ToXml()
    $user = $xml.Event.EventData.Data | Where-Object Name -eq 'TargetUserName' | Select-Object -ExpandProperty '#text'

    if (-not $users.ContainsKey($user)) {
        $users[$user] = [PSCustomObject]@{
            UserName        = $user
            FailedLogon     = 0
            SuccessfulLogon = 0
            CreatedRecently = $false
            AddedToGroup    = @()
        }
    }

    $users[$user].CreatedRecently = $true
}

Get-WinEvent -FilterHashtable @{ LogName = "Security"; Id = 4732; StartTime = (Get-Date).AddHours(-24) } -ErrorAction SilentlyContinue |
ForEach-Object {
    $xml = [xml]$_.ToXml()
    $user = $xml.Event.EventData.Data | Where-Object Name -eq 'TargetUserName' | Select-Object -ExpandProperty '#text'
    $group = $xml.Event.EventData.Data | Where-Object Name -eq 'Group Name' | Select-Object -ExpandProperty '#text'

    if (-not $users.ContainsKey($user)) {
        $users[$user] = [PSCustomObject]@{
            UserName        = $user
            FailedLogon     = 0
            SuccessfulLogon = 0
            CreatedRecently = $false
            AddedToGroup    = @()
        }
    }

    $users[$user].AddedToGroup += $group
}

Foreach ( $user in $users.Values ) {
    if ( $user.FailedLogon -gt 5 -and $user.SuccessfulLogon -gt 0) {
        Write-Host "[CRITICAL] Possible brute force: $($user.UserName)" -ForegroundColor Red
    } 
    if ( $user.CreatedRecently -and $user.AddedToGroup.Count -gt 0 ) {
        Write-Host "[CRITICAL] Privilege escalation: $($user.UserName) added to: $($user.AddedToGroup -join ', ')" -ForegroundColor Red
    }
    if ( $user.FailedLogon -gt 5 -and $user.SuccessfulLogon -eq 0 ) {
        Write-Host "[WARNING] Brute force attempt (no success): $($user.UserName)" -ForegroundColor Yellow
    }
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
Write-Host $timestamp
$users.Values | Select-Object UserName, FailedLogon, SuccessfulLogon, CreatedRecently, AddedToGroup | Format-Table -AutoSize