<#
.SYNOPSIS
Dashboard 10: Device Anomalies & Driver Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_10"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "  DASHBOARD 10: DEVICE ANOMALIES & DRIVERS   " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Launch Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
Start-Process -FilePath "mmc.exe" -ArgumentList "devmgmt.msc"
Start-Process -FilePath "msinfo32.exe"
Start-Process -FilePath "mmc.exe" -ArgumentList "compmgmt.msc"

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*Device Manager*" -Quadrant "Top-Left"
Set-AppGrid -WindowTitlePattern "*System Information*" -Quadrant "Top-Right"
Set-AppGrid -WindowTitlePattern "*Computer Management*" -Quadrant "Bottom-Right"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 10_Harvest_Anomalies.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 10_PnP_Driver_Reset.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 10..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Harvesters\10_Harvest_Anomalies.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 10..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Remedies\10_PnP_Driver_Reset.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}