<#
.SYNOPSIS
Dashboard 07: Startup & Ghost Processes Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_07"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "  DASHBOARD 07: STARTUPS & GHOST PROCESSES   " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$App_Autoruns = Join-Path $global:Path_PortableApps "AutorunsPortable\AutorunsPortable.exe"

# 1. Launch Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
if (Test-Path $App_Autoruns) { Start-Process -FilePath $App_Autoruns } else { Write-Host "[-] Autoruns not found." -ForegroundColor Red }
Start-Process -FilePath "taskmgr.exe" -ArgumentList "/0 /startup"
Start-Process -FilePath "mmc.exe" -ArgumentList "services.msc"

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*Autoruns*" -Quadrant "Top-Right"
Set-AppGrid -WindowTitlePattern "*Task Manager*" -Quadrant "Top-Left"
Set-AppGrid -WindowTitlePattern "*Services*" -Quadrant "Bottom-Right"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 07_Harvest_Startups.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 07_Nuke_Unknown_Startups.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 07..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Harvesters\07_Harvest_Startups.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 07..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Remedies\07_Nuke_Unknown_Startups.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}