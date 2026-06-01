$Reg = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"


foreach ( $entry in $Reg ) {
    if (-not (Test-Path $entry)) { continue }

    $Properties = (Get-ItemProperty -Path $entry).psobject.properties | 
    Where-Object { $_.Name -notmatch "^PS" }

    $Names = $Properties | Select-Object -ExpandProperty Name

    $Paths = $Properties | Select-Object -ExpandProperty Value

    for( $i = 0; $i -lt $Names.Count; $i++ ){
        if ( $Paths[$i] -match "(Temp|AppData|Public|Downloads).*\.(exe|bat|ps1|vbs|cmd|dll)" ) {
            Write-Host "[ALERT] Suspicious entry: $($Names[$i]) -> $($Paths[$i])"
        }
    }
} 
Write-Host "Scan complete."