<#
.SYNOPSIS
Dashboard 03: User Accounts & Access Hub
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$host.UI.RawUI.WindowTitle = "USBEX_Terminal_03"

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "    DASHBOARD 03: USER ACCOUNTS & ACCESS     " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Launch Native Array
Write-Host "[*] Launching Diagnostic Array..." -ForegroundColor Yellow
Start-Process -FilePath "mmc.exe" -ArgumentList "eventvwr.msc /c:Security"
$CmdArgs = '/k "title Native_User_Audit & color 0E & echo === ACTIVE LOCAL USERS === & net user & echo. & echo === LOCAL ADMINISTRATORS === & net localgroup administrators"'
Start-Process -FilePath "cmd.exe" -ArgumentList $CmdArgs

# 2. Snap to Grid
Set-AppGrid -WindowTitlePattern "*Event Viewer*" -Quadrant "Right"
Set-AppGrid -WindowTitlePattern "*Native_User_Audit*" -Quadrant "Top-Left"
Set-TerminalGrid -Quadrant "Bottom-Left"

# 3. Command Hub Loop
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "                 COMMAND HUB                 " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "[F6]  DOCUMENT -> Run 03_Harvest_Users.ps1" -ForegroundColor Yellow
Write-Host "[F5]  REMEDY   -> Run 03_Account_Lockdown.ps1" -ForegroundColor Yellow
Write-Host "[ESC] EXIT     -> Close Dashboard Terminal" -ForegroundColor Gray

while ($true) {
    $Key = [System.Console]::ReadKey($true)
    if ($Key.Key -eq 'F6') {
        Write-Host "`n[+] Triggering Harvester 03..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Harvesters\03_Harvest_Users.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'F5') {
        Write-Host "`n[!] Triggering Remedy 03..." -ForegroundColor Green
        $ScriptPath = Join-Path $global:Path_Scripts "Remedies\03_Account_Lockdown.ps1"
        if (Test-Path $ScriptPath) { & $ScriptPath } else { Write-Host "[-] Not found: $ScriptPath" -ForegroundColor Red }
    } elseif ($Key.Key -eq 'Escape') {
        Write-Host "`n[!] Escape pressed. Closing Dashboard..." -ForegroundColor Red
        break
    }
}