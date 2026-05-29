<#
.SYNOPSIS
Remedy 05: Kill Rogue Sockets
.DESCRIPTION
Terminates unauthorized ESTABLISHED network connections and gracefully kills their parent processes running from risky directories.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_05_KillRogueSockets_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 05: KILL ROGUE SOCKETS ==="

try {
    Write-RemedyLog "[*] Identifying all ESTABLISHED TCP connections..."
    $ActiveConnections = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -and $_.RemoteAddress -notmatch "^127\.|^0\.|^::" }
    
    $SuspiciousPaths = @("AppData\Local\Temp", "ProgramData", "Users\Public")
    $KilledCount = 0

    foreach ($Conn in $ActiveConnections) {
        $Proc = Get-Process -Id $Conn.OwningProcess -ErrorAction SilentlyContinue
        if ($Proc -and $Proc.Path) {
            $IsRogue = $false
            foreach ($RiskPath in $SuspiciousPaths) {
                if ($Proc.Path -match [regex]::Escape($RiskPath)) { $IsRogue = $true; break }
            }

            if ($IsRogue) {
                Write-RemedyLog "[!] Rogue socket detected. Remote IP: $($Conn.RemoteAddress):$($Conn.RemotePort) -> PID: $($Proc.Id) ($($Proc.ProcessName))"
                Write-RemedyLog "[*] Terminating Process ID $($Proc.Id) executing from $($Proc.Path)..."
                Stop-Process -Id $Proc.Id -Force -ErrorAction SilentlyContinue
                Write-RemedyLog "[+] Process $($Proc.ProcessName) terminated successfully."
                $KilledCount++
            }
        }
    }

    if ($KilledCount -eq 0) {
        Write-RemedyLog "[+] No rogue connections found running from restricted directories."
    } else {
        Write-RemedyLog "[+] Swept and destroyed $KilledCount rogue processes."
    }

} catch {
    Write-RemedyLog "[-] FATAL ERROR during Socket Termination: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 05 COMPLETE ==="