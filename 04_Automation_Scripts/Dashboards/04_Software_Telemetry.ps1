<#
.SYNOPSIS
Dashboard 04: Software & Licensing Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_04"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "     DASHBOARD 04: SOFTWARE & LICENSING      " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$App_WizTree = Join-Path $global:Path_PortableApps "WizTreePortable\WizTreePortable.exe"
$App_Geek = Join-Path $global:Path_PortableApps "GeekUninstallerPortable\GeekUninstallerPortable.exe"

# 1. Launch Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
if (Test-Path $App_WizTree) { Start-Process -FilePath $App_WizTree } else { Write-Host "[-] WizTree not found." -ForegroundColor Red }
if (Test-Path $App_Geek) { Start-Process -FilePath $App_Geek } else { Write-Host "[-] GeekUninstaller not found." -ForegroundColor Red }

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*WizTree*" -Quadrant "Top"
Set-AppGrid -WindowTitlePattern "*Geek Uninstaller*" -Quadrant "Bottom-Right"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 04_Harvest_Software.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 04_Bloatware_Purge.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 04..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Harvesters\04_Harvest_Software.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 04..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Remedies\04_Bloatware_Purge.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}