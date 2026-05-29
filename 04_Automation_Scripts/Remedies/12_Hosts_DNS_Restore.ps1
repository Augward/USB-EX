<#
.SYNOPSIS
Remedy 12: Hosts & DNS Restore
.DESCRIPTION
Clears proxy settings cache and completely overwrites a poisoned hosts file with the safe Microsoft template.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_12_HostsDNSRestore_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 12: HOSTS & DNS RESTORE ==="

try {
    Write-RemedyLog "[*] Resetting WinHTTP Proxy Configurations..."
    $ProxyReset = Invoke-Expression "netsh winhttp reset proxy"
    Write-RemedyLog "[+] WinHTTP Proxy Reset: $ProxyReset"

    Write-RemedyLog "[*] Restoring default Windows hosts file..."
    $HostsPath = "C:\Windows\System32\drivers\etc\hosts"
    
    $DefaultHosts = @"
# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host

# localhost name resolution is handled within DNS itself.
#       127.0.0.1       localhost
#       ::1             localhost
"@

    # Remove Read-Only attribute if malware set it
    if (Test-Path $HostsPath) {
        Set-ItemProperty -Path $HostsPath -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
    }
    
    Set-Content -Path $HostsPath -Value $DefaultHosts -Force -ErrorAction Stop
    Write-RemedyLog "[+] Hosts file successfully purged and replaced with clean template."

} catch {
    Write-RemedyLog "[-] FATAL ERROR during Hosts/DNS Restore: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 12 COMPLETE ==="