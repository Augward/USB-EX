<#
.SYNOPSIS
Dashboard 01: Hardware & Storage Health Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_01"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "   DASHBOARD 01: HARDWARE & STORAGE HEALTH   " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$App_HWMonitor = Join-Path $global:Path_PortableApps "HWMonitorPortable\HWMonitorPortable.exe"
$App_Speccy = Join-Path $global:Path_PortableApps "specPortable\specPortable.exe"
$App_CrystalDiskInfo = Join-Path $global:Path_PortableApps "CrystalDiskInfoPortable\CrystalDiskInfoPortable.exe"

# 1. Launch Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
if (Test-Path $App_HWMonitor) { Start-Process -FilePath $App_HWMonitor } else { Write-Host "[-] HWMonitor not found." -ForegroundColor Red }
if (Test-Path $App_CrystalDiskInfo) { Start-Process -FilePath $App_CrystalDiskInfo } else { Write-Host "[-] CrystalDiskInfo not found." -ForegroundColor Red }
if (Test-Path $App_Speccy) { Start-Process -FilePath $App_Speccy } else { Write-Host "[-] Speccy not found." -ForegroundColor Red }

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*HWMonitor*" -Quadrant "Top-Right"
Set-AppGrid -WindowTitlePattern "*Speccy*" -Quadrant "Top-Left"
Set-AppGrid -WindowTitlePattern "*CrystalDiskInfo*" -Quadrant "Bottom-Right"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 01_Harvest_Hardware.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 01_System_Scrub.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 01..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Harvesters\01_Harvest_Hardware.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 01..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Remedies\01_System_Scrub.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}