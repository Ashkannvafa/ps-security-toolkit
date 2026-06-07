try {
    $localUsers = Get-LocalUser
    $administrators = (Get-LocalGroupMember Administrators).Name -replace '.*\\'
    $users = Get-Item -Path "C:\Users\*" | Where-Object { $_.PSChildName -ne "Public" }
    
    foreach ( $user in $localUsers ) {
        $isAdmin = $administrators -contains $user.Name
    
        if ( $null -ne $user.LastLogon -and $user.LastLogon -lt (Get-Date).AddDays(-30) ) {
            Write-Host "[WARNING] $($user.Name) hasn't logged in for 30+ days" -ForegroundColor Yellow
        }
        if ( -not $user.Enabled -and $isAdmin ) {
            Write-Host "[CRITICAL] $($user.Name) is disabled but still in Administrators" -ForegroundColor Red
        }
        if ( $null -eq $user.PasswordExpires ) {
            Write-Host "[WARNING] $($user.Name) password never expires" -ForegroundColor Yellow
            if ( -not $user.Enabled ) {
                Write-Host "[CRITICAL] $($user.Name) password never expires AND account is inactive" -ForegroundColor Red
            }
        }
        $userFolder = $users | Where-Object { $_.PSChildName -eq $user.Name }
        if ( $null -ne $userFolder -and $userFolder.CreationTime -gt (Get-Date).AddDays(-7) ) {
            Write-Host "[WARNING] $($user.Name) account created within last 7 days" -ForegroundColor Yellow
            if ( $isAdmin ) {
                Write-Host "[CRITICAL] $($user.Name) is a new account AND in Administrators" -ForegroundColor Red
            }
        }
}
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}