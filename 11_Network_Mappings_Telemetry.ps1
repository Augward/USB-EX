<#
.SYNOPSIS
Dashboard 11: Network Mappings & Shares Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_11"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "   DASHBOARD 11: NETWORK MAPPINGS & SHARES   " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$App_FreeCmd = Join-Path $global:Path_PortableApps "FreeCommanderPortable\FreeCommanderPortable.exe"

# 1. Launch Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
Start-Process -FilePath "mmc.exe" -ArgumentList "fsmgmt.msc"
if (Test-Path $App_FreeCmd) { Start-Process -FilePath $App_FreeCmd } else { Write-Host "[-] FreeCommander not found." -ForegroundColor Red }
Start-Process -FilePath "msconfig.exe"

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*Shared Folders*" -Quadrant "Top-Right"
Set-AppGrid -WindowTitlePattern "*Desktop*" -Quadrant "Top-Left"
Set-AppGrid -WindowTitlePattern "*System Configuration*" -Quadrant "Bottom-Right"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 11_Harvest_Mappings.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 11_SMB_Hardening.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 11..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Harvesters\11_Harvest_Mappings.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 11..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Remedies\11_SMB_Hardening.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}