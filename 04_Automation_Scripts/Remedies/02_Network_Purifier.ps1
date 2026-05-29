<#
.SYNOPSIS
Remedy 02: Network Purifier
.DESCRIPTION
Silently flushes DNS, resets Winsock, releases/renews IP, and clears ARP cache.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_02_NetworkPurifier_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 02: NETWORK PURIFIER ==="
Write-RemedyLog "Target Machine: $env:COMPUTERNAME"

try {
    Write-RemedyLog "[*] Flushing DNS Cache..."
    $DNSFlush = Invoke-Expression "ipconfig /flushdns"
    Write-RemedyLog "[+] DNS Cache Flushed: $DNSFlush"

    Write-RemedyLog "[*] Resetting Winsock Catalog..."
    $WinsockReset = Invoke-Expression "netsh winsock reset"
    Write-RemedyLog "[+] Winsock Catalog Reset."

    Write-RemedyLog "[*] Resetting TCP/IP Stack..."
    $TCPReset = Invoke-Expression "netsh int ip reset"
    Write-RemedyLog "[+] TCP/IP Stack Reset."

    Write-RemedyLog "[*] Clearing ARP Cache..."
    $ARPReset = Invoke-Expression "arp -d *"
    Write-RemedyLog "[+] ARP Cache Cleared."

    Write-RemedyLog "[*] Releasing and Renewing IPv4 Addresses..."
    Invoke-Expression "ipconfig /release" | Out-Null
    Start-Sleep -Seconds 2
    Invoke-Expression "ipconfig /renew" | Out-Null
    Write-RemedyLog "[+] IP Addresses Renewed successfully."

} catch {
    Write-RemedyLog "[-] FATAL ERROR during Network Purification: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 02 COMPLETE ==="
Write-RemedyLog "[!] NOTE: A system reboot is highly recommended to finalize Winsock configurations."