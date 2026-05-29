<#
.SYNOPSIS
Remedy 06: Force Shields Up
.DESCRIPTION
Forces a Defender signature update, enables maximum UAC, and turns all firewall profiles ON.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_06_ForceShieldsUp_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 06: FORCE SHIELDS UP ==="

try {
    Write-RemedyLog "[*] Enforcing strict Windows Firewall profiles (Domain, Private, Public)..."
    Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] All Windows Firewall profiles set to ON."

    Write-RemedyLog "[*] Hardening User Account Control (UAC) to maximum default..."
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    Set-ItemProperty -Path $RegPath -Name "EnableLUA" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $RegPath -Name "ConsentPromptBehaviorAdmin" -Value 5 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $RegPath -Name "PromptOnSecureDesktop" -Value 1 -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] UAC parameters restored to Microsoft secure defaults."

    Write-RemedyLog "[*] Triggering Windows Defender Signature Update..."
    Update-MpSignature -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] Defender Signatures requested refresh."
    
    Write-RemedyLog "[*] Forcing Real-Time Protection ON..."
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] Defender Real-Time Monitoring is strictly enabled."

} catch {
    Write-RemedyLog "[-] FATAL ERROR during Security Hardening: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 06 COMPLETE ==="