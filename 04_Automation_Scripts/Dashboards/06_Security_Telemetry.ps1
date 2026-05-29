<#
.SYNOPSIS
Dashboard 06: Security Posture & AV Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_06"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "     DASHBOARD 06: SECURITY POSTURE & AV     " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$App_Emsisoft = Join-Path $global:Path_PortableApps "EmsisoftEmergencyKitPortable\EmsisoftEmergencyKitPortable.exe"

# 1. Launch Universal Native Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
if (Test-Path $App_Emsisoft) { Start-Process -FilePath $App_Emsisoft } else { Write-Host "[-] Emsisoft Emergency Kit not found." -ForegroundColor Red }
Start-Process -FilePath "control.exe" -ArgumentList "firewall.cpl"
Start-Process -FilePath "windowsdefender://" # Spawns Windows Security Center

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*Emsisoft*" -Quadrant "Top-Right"
Set-AppGrid -WindowTitlePattern "*Firewall*" -Quadrant "Top-Left"
Set-AppGrid -WindowTitlePattern "*Windows Security*" -Quadrant "Bottom-Right"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 06_Harvest_Security.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 06_Force_Shields_Up.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 06..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Harvesters\06_Harvest_Security.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 06..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Remedies\06_Force_Shields_Up.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}