<#
.SYNOPSIS
Remedy 03: Account Lockdown
.DESCRIPTION
Disables the local Guest account, forces logoff of stale RDP sessions, and locks the workstation.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_03_AccountLockdown_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 03: ACCOUNT LOCKDOWN ==="

try {
    Write-RemedyLog "[*] Hardening Built-In Accounts..."
    $GuestAccount = Get-LocalUser -Name "Guest" -ErrorAction SilentlyContinue
    if ($GuestAccount.Enabled) {
        Disable-LocalUser -Name "Guest" -ErrorAction Stop
        Write-RemedyLog "[+] Local Guest account strictly disabled."
    } else {
        Write-RemedyLog "[*] Local Guest account is already disabled."
    }

    Write-RemedyLog "[*] Terminating Disconnected/Stale Logon Sessions..."
    $Sessions = quser 2>&1
    if ($Sessions -notmatch "No User exists") {
        foreach ($Session in $Sessions) {
            if ($Session -match "Disc") {
                $SessionId = ($Session -split '\s+')[2]
                if ($SessionId -match '\d') {
                    logoff $SessionId
                    Write-RemedyLog "[+] Terminated Disconnected Session ID: $SessionId"
                }
            }
        }
    } else {
        Write-RemedyLog "[*] No active/disconnected remote sessions found."
    }

    Write-RemedyLog "[*] Initiating Workstation Lock..."
    rundll32.exe user32.dll,LockWorkStation
    Write-RemedyLog "[+] Workstation successfully locked to prevent unauthorized physical access."

} catch {
    Write-RemedyLog "[-] FATAL ERROR during Account Lockdown: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 03 COMPLETE ==="