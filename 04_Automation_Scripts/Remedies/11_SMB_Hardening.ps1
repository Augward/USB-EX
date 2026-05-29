<#
.SYNOPSIS
Remedy 11: SMB Hardening
.DESCRIPTION
Silently forces the disabling of vulnerable SMBv1 via registry and restricts anonymous share access.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_11_SMBHardening_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 11: SMB HARDENING ==="

try {
    Write-RemedyLog "[*] Evaluating SMBv1 Server state..."
    $SMB1State = Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol
    
    if ($SMB1State.EnableSMB1Protocol -eq $true) {
        Write-RemedyLog "[!] VULNERABILITY DETECTED: SMBv1 is ACTIVE. Executing kill sequence..."
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction SilentlyContinue
        Write-RemedyLog "[+] SMBv1 Protocol strictly disabled via ServerConfiguration."
    } else {
        Write-RemedyLog "[*] SMBv1 Protocol is already disabled."
    }

    Write-RemedyLog "[*] Hardening Null Session / Anonymous Share Access via Registry..."
    $LSA = "HKLM:\System\CurrentControlSet\Control\Lsa"
    Set-ItemProperty -Path $LSA -Name "RestrictAnonymous" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $LSA -Name "RestrictAnonymousSAM" -Value 1 -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] Anonymous network enumeration heavily restricted."

} catch {
    Write-RemedyLog "[-] FATAL ERROR during SMB Hardening: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 11 COMPLETE ==="