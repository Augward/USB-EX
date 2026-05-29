<#
.SYNOPSIS
Remedy 04: Bloatware Purge
.DESCRIPTION
Silently rips out consumer bloatware and Windows telemetry via PowerShell Appx commands.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_04_BloatwarePurge_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 04: BLOATWARE PURGE ==="

$BloatwareList = @(
    "*BingNews*", "*BingWeather*", "*CandyCrush*", "*DisneyMagic*", 
    "*Facebook*", "*HiddenCity*", "*MarchofEmpires*", "*MinecraftUWP*", 
    "*Netflix*", "*OneNote*", "*SkypeApp*", "*SolitaireCollection*", 
    "*Spotify*", "*Twitter*", "*WindowsAlarms*", "*WindowsFeedbackHub*", 
    "*WindowsMaps*", "*WindowsSoundRecorder*", "*XboxApp*", "*XboxSpeechToTextOverlay*",
    "*ZuneMusic*", "*ZuneVideo*"
)

try {
    Write-RemedyLog "[*] Targetting known Windows UWP Bloatware arrays..."
    foreach ($App in $BloatwareList) {
        $FoundApp = Get-AppxPackage -Name $App -AllUsers -ErrorAction SilentlyContinue
        if ($FoundApp) {
            Write-RemedyLog "[*] Removing UWP Package: $($FoundApp.Name)"
            Get-AppxPackage -Name $App -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Write-RemedyLog "[+] Successfully stripped: $($FoundApp.Name)"
        }
    }

    Write-RemedyLog "[*] Disabling Windows Telemetry (DiagTrack)..."
    Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
    Write-RemedyLog "[+] Telemetry Service Disabled and Registry restricted."

} catch {
    Write-RemedyLog "[-] FATAL ERROR during Bloatware Purge: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 04 COMPLETE ==="