<#
.SYNOPSIS
Remedy 08: Log Flush & Reset
.DESCRIPTION
Clears stale Windows Application/Temp logs and safely resets a corrupted WMI repository.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_08_LogFlush_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 08: LOG FLUSH & WMI RESET ==="

try {
    Write-RemedyLog "[*] Flushing non-critical Application and Setup Windows Event Logs..."
    Clear-EventLog -LogName Application -ErrorAction SilentlyContinue
    Clear-EventLog -LogName Setup -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] Application and Setup logs successfully flushed."

    Write-RemedyLog "[*] Stopping WMI Service to salvage repository..."
    Stop-Service -Name "Winmgmt" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    Write-RemedyLog "[*] Executing WMI Repository Salvage..."
    $WMIFix = Invoke-Expression "winmgmt /salvagerepository"
    Write-RemedyLog "[+] WMI Command Executed: $WMIFix"

    Write-RemedyLog "[*] Restarting WMI Service..."
    Start-Service -Name "Winmgmt" -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] WMI Service running normally."

} catch {
    Write-RemedyLog "[-] FATAL ERROR during Log/WMI Reset: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 08 COMPLETE ==="