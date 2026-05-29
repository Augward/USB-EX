<#
.SYNOPSIS
Dashboard 02: Network Traffic & Routing Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_02"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "   DASHBOARD 02: NETWORK TRAFFIC & ROUTING   " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$App_TCPView = Join-Path $global:Path_PortableApps "TCPViewPortable\TCPViewPortable.exe"
$App_AngryIPScanner = Join-Path $global:Path_PortableApps "AngryIPScannerPortable\AngryIPScannerPortable.exe"

# 1. Launch Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
if (Test-Path $App_TCPView) { Start-Process -FilePath $App_TCPView } else { Write-Host "[-] TCPView not found." -ForegroundColor Red }
if (Test-Path $App_AngryIPScanner) { Start-Process -FilePath $App_AngryIPScanner } else { Write-Host "[-] Angry IP Scanner not found." -ForegroundColor Red }

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*TCPView*" -Quadrant "Right"
Set-AppGrid -WindowTitlePattern "*Angry IP Scanner*" -Quadrant "Top-Left"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 02_Harvest_Network.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 02_Network_Purifier.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 02..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Harvesters\02_Harvest_Network.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 02..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Remedies\02_Network_Purifier.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}