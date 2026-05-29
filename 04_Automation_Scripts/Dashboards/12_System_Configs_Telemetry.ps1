<#
.SYNOPSIS
Dashboard 12: Deep System Configs Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_12"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "      DASHBOARD 12: DEEP SYSTEM CONFIGS      " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$App_RegShot = Join-Path $global:Path_PortableApps "RegshotPortable\RegshotPortable.exe"
$App_GrepWin = Join-Path $global:Path_PortableApps "grepWinPortable\grepWinPortable.exe"

# 1. Launch Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
Start-Process -FilePath "regedit.exe"
if (Test-Path $App_RegShot) { Start-Process -FilePath $App_RegShot } else { Write-Host "[-] Registry Shot not found." -ForegroundColor Red }
if (Test-Path $App_GrepWin) { Start-Process -FilePath $App_GrepWin } else { Write-Host "[-] GrepWin not found." -ForegroundColor Red }

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*Registry Editor*" -Quadrant "Top-Left"
Set-AppGrid -WindowTitlePattern "*RegShot*" -Quadrant "Top-Right"
Set-AppGrid -WindowTitlePattern "*grepWin*" -Quadrant "Bottom-Right"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 12_Harvest_Configs.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 12_Hosts_DNS_Restore.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 12..." -ForegroundColor Green
        # Assuming Harvester 12 exists
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 12..." -ForegroundColor Green
        # Assuming Remedy 12 exists
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}