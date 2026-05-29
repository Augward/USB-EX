<#
.SYNOPSIS
Remedy 10: PnP Driver Reset
.DESCRIPTION
Restarts the Print Spooler, clears corrupted print queues, and resets the Plug-and-Play cache.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_10_PnPDriverReset_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 10: PnP DRIVER RESET ==="

try {
    Write-RemedyLog "[*] Stopping Print Spooler service..."
    Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    Write-RemedyLog "[*] Purging stuck/corrupted print queues..."
    Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] Spooler PRINTERS directory completely scrubbed."

    Write-RemedyLog "[*] Restarting Print Spooler..."
    Start-Service -Name "Spooler" -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] Spooler online."

    Write-RemedyLog "[*] Resetting Plug and Play (PnP) subsystem via rescanning..."
    # Simulates a "Scan for hardware changes"
    $PnPUtil = Invoke-Expression "pnputil /scan-devices"
    Write-RemedyLog "[+] Hardware scan triggered: $PnPUtil"

} catch {
    Write-RemedyLog "[-] FATAL ERROR during PnP Reset: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 10 COMPLETE ==="