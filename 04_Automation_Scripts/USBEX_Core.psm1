<#
.SYNOPSIS
USB-EX Master Core Module
.DESCRIPTION
Handles dynamic pathing, GUI grid manipulation via Win32 API, and standardized JSON data serialization.
#>

# ==========================================
# 1. Dynamic Pathing Engine
# ==========================================
# Finds the root of the USB drive dynamically
$global:USBRoot = (Resolve-Path "$PSScriptRoot\..").Path

# Application and Script Paths
$global:Path_PortableApps = Join-Path $global:USBRoot "02_PortableApps\PortableApps\PortableApps"
$global:Path_Scripts      = Join-Path $global:USBRoot "04_Automation_Scripts"

# Data Output Paths (Phases 2, 3, and 4)
$global:Path_DataOutput       = Join-Path $global:USBRoot "06_Data_Recovery_Security\Harvest_Logs"
$global:Path_RemediationLogs  = Join-Path $global:USBRoot "06_Data_Recovery_Security\Remediation_Logs"
$global:Path_RecoveredData    = Join-Path $global:USBRoot "06_Data_Recovery_Security\Recovered_Data"

# Ensure all critical output directories exist
if (-not (Test-Path $global:Path_DataOutput))      { New-Item -ItemType Directory -Path $global:Path_DataOutput -Force | Out-Null }
if (-not (Test-Path $global:Path_RemediationLogs)) { New-Item -ItemType Directory -Path $global:Path_RemediationLogs -Force | Out-Null }
if (-not (Test-Path $global:Path_RecoveredData))   { New-Item -ItemType Directory -Path $global:Path_RecoveredData -Force | Out-Null }

# ==========================================
# 2. JSON Standardization Engine
# ==========================================
Function Export-USBEXData {
    param(
        [Parameter(Mandatory=$true)][string]$AuditType,
        [Parameter(Mandatory=$true)][object]$DataPayload,
        [Parameter(Mandatory=$false)][switch]$ReturnObjectInstead
    )
    
    $Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $ComputerName = $env:COMPUTERNAME
    $FileName = "${ComputerName}_${AuditType}_${Timestamp}.json"
    $FilePath = Join-Path $global:Path_DataOutput $FileName

    if ($ReturnObjectInstead) {
        return $DataPayload
    } else {
        $DataPayload | ConvertTo-Json -Depth 10 | Out-File -FilePath $FilePath -Encoding UTF8
        Write-Host "[+] Exported $AuditType data to $FileName" -ForegroundColor Green
    }
}

# ==========================================
# 3. GUI Grid Engine (C# P/Invoke)
# ==========================================
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class USBEX_Win32 {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
}
"@

Function Set-AppGrid {
    param (
        [Parameter(Mandatory=$false)]
        [string]$WindowTitlePattern,

        [Parameter(Mandatory=$false)]
        [string]$ProcessNamePattern,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Top-Left', 'Top-Right', 'Bottom-Left', 'Bottom-Right', 'Top', 'Bottom', 'Left', 'Right', 'Full')]
        [string]$Quadrant
    )

    $timeout = 15
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $targetProcess = $null

    if ($ProcessNamePattern) {
        Write-Host "[*] Waiting for Process matching '$ProcessNamePattern'..." -ForegroundColor Cyan
    } else {
        Write-Host "[*] Waiting for Window Title matching '$WindowTitlePattern'..." -ForegroundColor Cyan
    }

    while ($stopwatch.Elapsed.TotalSeconds -lt $timeout) {
        if ($ProcessNamePattern) {
            $targetProcess = Get-Process | Where-Object { $_.ProcessName -like $ProcessNamePattern -and $_.ProcessName -notmatch "Portable" -and $_.MainWindowHandle -ne 0 } | Select-Object -First 1
        } elseif ($WindowTitlePattern) {
            $targetProcess = Get-Process | Where-Object { $_.MainWindowTitle -like $WindowTitlePattern -and $_.MainWindowHandle -ne 0 } | Select-Object -First 1
        }
        
        if ($targetProcess) { break }
        Start-Sleep -Milliseconds 250
    }

    if (-not $targetProcess) {
        $FailedTarget = if ($ProcessNamePattern) { $ProcessNamePattern } else { $WindowTitlePattern }
        Write-Host "[-] Timeout: Could not find '$FailedTarget' within $timeout seconds." -ForegroundColor Red
        return
    }

    # Dynamic Screen Calculation based on Monitor Resolution
    Add-Type -AssemblyName System.Windows.Forms
    $WorkArea = [System.Windows.Forms.SystemInformation]::WorkingArea
    $HalfW = [math]::Round($WorkArea.Width / 2)
    $HalfH = [math]::Round($WorkArea.Height / 2)
    $FullW = $WorkArea.Width
    $FullH = $WorkArea.Height

    # Translate the Quadrant name into exact screen coordinates
    switch ($Quadrant) {
        'Top-Left'     { $X = $WorkArea.X;          $Y = $WorkArea.Y;          $W = $HalfW; $H = $HalfH }
        'Top-Right'    { $X = $WorkArea.X + $HalfW; $Y = $WorkArea.Y;          $W = $HalfW; $H = $HalfH }
        'Bottom-Left'  { $X = $WorkArea.X;          $Y = $WorkArea.Y + $HalfH; $W = $HalfW; $H = $HalfH }
        'Bottom-Right' { $X = $WorkArea.X + $HalfW; $Y = $WorkArea.Y + $HalfH; $W = $HalfW; $H = $HalfH }
        'Top'          { $X = $WorkArea.X;          $Y = $WorkArea.Y;          $W = $FullW; $H = $HalfH }
        'Bottom'       { $X = $WorkArea.X;          $Y = $WorkArea.Y + $HalfH; $W = $FullW; $H = $HalfH }
        'Left'         { $X = $WorkArea.X;          $Y = $WorkArea.Y;          $W = $HalfW; $H = $FullH }
        'Right'        { $X = $WorkArea.X + $HalfW; $Y = $WorkArea.Y;          $W = $HalfW; $H = $FullH }
        'Full'         { $X = $WorkArea.X;          $Y = $WorkArea.Y;          $W = $FullW; $H = $FullH }
    }

    # Physically move and resize the window
    [USBEX_Win32]::SetWindowPos($targetProcess.MainWindowHandle, [IntPtr]::Zero, $X, $Y, $W, $H, 0x0040)
    Write-Host "[+] Snapped process '$($targetProcess.ProcessName)' to $Quadrant" -ForegroundColor Green
}

Function Set-TerminalGrid {
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('Top-Left', 'Top-Right', 'Bottom-Left', 'Bottom-Right', 'Top', 'Bottom', 'Left', 'Right', 'Full')]
        [string]$Quadrant = 'Bottom-Left' # Defaults to Bottom-Left for all Dashboards
    )
    
    Add-Type -AssemblyName System.Windows.Forms
    $WorkArea = [System.Windows.Forms.SystemInformation]::WorkingArea
    $HalfW = [math]::Round($WorkArea.Width / 2)
    $HalfH = [math]::Round($WorkArea.Height / 2)
    $FullW = $WorkArea.Width
    $FullH = $WorkArea.Height

    switch ($Quadrant) {
        'Top-Left'     { $X = $WorkArea.X;          $Y = $WorkArea.Y;          $W = $HalfW; $H = $HalfH }
        'Top-Right'    { $X = $WorkArea.X + $HalfW; $Y = $WorkArea.Y;          $W = $HalfW; $H = $HalfH }
        'Bottom-Left'  { $X = $WorkArea.X;          $Y = $WorkArea.Y + $HalfH; $W = $HalfW; $H = $HalfH }
        'Bottom-Right' { $X = $WorkArea.X + $HalfW; $Y = $WorkArea.Y + $HalfH; $W = $HalfW; $H = $HalfH }
        'Top'          { $X = $WorkArea.X;          $Y = $WorkArea.Y;          $W = $FullW; $H = $HalfH }
        'Bottom'       { $X = $WorkArea.X;          $Y = $WorkArea.Y + $HalfH; $W = $FullW; $H = $HalfH }
        'Left'         { $X = $WorkArea.X;          $Y = $WorkArea.Y;          $W = $HalfW; $H = $FullH }
        'Right'        { $X = $WorkArea.X + $HalfW; $Y = $WorkArea.Y;          $W = $HalfW; $H = $FullH }
        'Full'         { $X = $WorkArea.X;          $Y = $WorkArea.Y;          $W = $FullW; $H = $FullH }
    }

    # Finds the PowerShell window running this exact dashboard
    $Proc = Get-Process | Where-Object { $_.MainWindowTitle -like "*USBEX_Terminal*" } | Select-Object -First 1
    
    if ($Proc) {
        [USBEX_Win32]::SetWindowPos($Proc.MainWindowHandle, [IntPtr]::Zero, $X, $Y, $W, $H, 0x0040)
        Write-Host "[+] Terminal securely anchored to $Quadrant." -ForegroundColor Green
    } else {
        Write-Host "[-] Could not snap Terminal." -ForegroundColor Yellow
    }
}