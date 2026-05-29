<#
.SYNOPSIS
Dashboard 08: System Event Logs Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_08"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "       DASHBOARD 08: SYSTEM EVENT LOGS       " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$App_WindowsLookup = Join-Path $global:Path_PortableApps "WindowsErrorLookupToolPortable\WindowsErrorLookupToolPortable.exe"

# 1. Launch Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
Start-Process -FilePath "mmc.exe" -ArgumentList "eventvwr.msc"
Start-Process -FilePath "perfmon.exe" -ArgumentList "/rel" # Reliability Monitor
if (Test-Path $App_WindowsLookup) { Start-Process -FilePath $App_WindowsLookup } else { Write-Host "[-] Windows Error Lookup Tool not found." -ForegroundColor Red }

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*Event Viewer*" -Quadrant "Top-Right"
Set-AppGrid -WindowTitlePattern "*Reliability Monitor*" -Quadrant "Top-Left"
Set-AppGrid -WindowTitlePattern "*Windows Error Lookup Tool*" -Quadrant "Bottom-Right"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 08_Harvest_Logs.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 08_Log_Flush_Reset.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 08..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Harvesters\08_Harvest_Logs.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 08..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Remedies\08_Log_Flush_Reset.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}