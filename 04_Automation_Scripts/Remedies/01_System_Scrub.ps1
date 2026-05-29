<#
.SYNOPSIS
Remedy 01: System Scrub (Silent Execution)
.DESCRIPTION
Clears temp files, prefetch, software distribution cache, and executes BleachBit silently.
#>

# 1. Import Core Engine
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

# Create a unique Log File for this specific run
$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_01_SystemScrub_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 01: SYSTEM SCRUB ==="
Write-RemedyLog "Target Machine: $env:COMPUTERNAME"
Write-RemedyLog "Executing User: $env:USERNAME"

# 2. Native Windows Cleanup
try {
    Write-RemedyLog "[*] Scrubbing System Temp (C:\Windows\Temp)..."
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] System Temp cleared of unlocked files."

    Write-RemedyLog "[*] Scrubbing User Temp ($env:TEMP)..."
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] User Temp cleared of unlocked files."

    Write-RemedyLog "[*] Scrubbing Windows Prefetch..."
    Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] Prefetch cache cleared."

    Write-RemedyLog "[*] Scrubbing SoftwareDistribution (Windows Update) Download Cache..."
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] SoftwareDistribution cleared."
} catch {
    Write-RemedyLog "[-] Error during native cleanup: $($_.Exception.Message)"
}

# 3. BleachBit Silent Execution
try {
    $App_BleachBit = Join-Path $global:Path_PortableApps "BleachBitPortable\BleachBitPortable.exe"
    
    if (Test-Path $App_BleachBit) {
        Write-RemedyLog "[*] Triggering BleachBit CLI..."
        # Runs BleachBit completely invisibly targeting safe junk caches
        $BBArgs = "--clean system.tmp system.trash system.clipboard system.recent_documents"
        $Proc = Start-Process -FilePath $App_BleachBit -ArgumentList $BBArgs -PassThru -Wait -NoNewWindow
        Write-RemedyLog "[+] BleachBit Execution Complete. Exit Code: $($Proc.ExitCode)"
    } else {
        Write-RemedyLog "[-] BleachBitPortable not found. Skipping advanced clean."
    }
} catch {
    Write-RemedyLog "[-] Error executing BleachBit: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 01 COMPLETE ==="
Write-Host "[+] System Scrub Complete. Log saved to 06_Data_Recovery_Security\Remediation_Logs" -ForegroundColor Green