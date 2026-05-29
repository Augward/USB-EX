<#
.SYNOPSIS
Dashboard 05: Live Connections & Sockets Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_05"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "  DASHBOARD 05: LIVE CONNECTIONS & SOCKETS   " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$App_SysInfo = Join-Path $global:Path_PortableApps "SystemInformerPortable\SystemInformerPortable.exe"

# 1. Launch Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
if (Test-Path $App_SysInfo) { Start-Process -FilePath $App_SysInfo } else { Write-Host "[-] SystemInformer not found." -ForegroundColor Red }
Start-Process -FilePath "perfmon.exe" -ArgumentList "/res" # Resource Monitor
Start-Process -FilePath "mmc.exe" -ArgumentList "wf.msc"   # Windows Firewall

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*System Informer*" -Quadrant "Bottom-Right"
Set-AppGrid -WindowTitlePattern "*Resource Monitor*" -Quadrant "Top-Right"
Set-AppGrid -WindowTitlePattern "*Windows Defender Firewall*" -Quadrant "Top-Left"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 05_Harvest_Connections.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 05_Kill_Rogue_Sockets.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 05..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Harvesters\05_Harvest_Connections.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 05..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Remedies\05_Kill_Rogue_Sockets.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}