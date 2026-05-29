<#
.SYNOPSIS
Dashboard 09: USB History & Transfer Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_09"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "    DASHBOARD 09: USB HISTORY & TRANSFERS    " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$App_FastCopy  = Join-Path $global:Path_PortableApps "FcpyPortable\FcpyPortable.exe"

# 1. Launch Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
Start-Process -FilePath "mmc.exe" -ArgumentList "diskmgmt.msc"
if (Test-Path $App_FastCopy) { Start-Process -FilePath $App_FastCopy } else { Write-Host "[-] FastCopy not found." -ForegroundColor Red }

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*Disk Management*" -Quadrant "Right"
Set-AppGrid -WindowTitlePattern "*FastCopy*" -Quadrant "Top-Left"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 09_Harvest_USBs.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 09_USB_History_Wipe.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 09..." -ForegroundColor Green
        # Assuming Harvester 09 exists
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 09..." -ForegroundColor Green
        # Assuming Remedy 09 exists
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}