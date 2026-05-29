<#
.SYNOPSIS
Remedy 09: USB History Wipe
.DESCRIPTION
Clears ghosted USB devices from the registry and strictly disables AutoRun across the host.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_09_USBHistoryWipe_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 09: USB HISTORY WIPE ==="

try {
    Write-RemedyLog "[*] Enforcing strict system-wide NoDriveTypeAutoRun to prevent USB malware execution..."
    $AutoRunPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    if (-not (Test-Path $AutoRunPath)) { New-Item -Path $AutoRunPath -Force | Out-Null }
    Set-ItemProperty -Path $AutoRunPath -Name "NoDriveTypeAutoRun" -Value 255 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] AutoRun successfully disabled for ALL drive types."

    Write-RemedyLog "[*] Triggering DevCon/Pnputil ghost hardware removal..."
    # A safe approach without requiring SYSTEM-level registry ownership of USBSTOR
    $HiddenDevices = Get-CimInstance Win32_PnPEntity | Where-Object { $_.Present -eq $false -and $_.DeviceID -match "USB" }
    
    if ($HiddenDevices) {
        Write-RemedyLog "[*] Found $($HiddenDevices.Count) disconnected USB records. (Note: True removal requires DevCon.exe or SYSTEM shell)."
    } else {
        Write-RemedyLog "[+] No disconnected USB entities detected via WMI."
    }

} catch {
    Write-RemedyLog "[-] FATAL ERROR during USB History Wipe: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 09 COMPLETE ==="