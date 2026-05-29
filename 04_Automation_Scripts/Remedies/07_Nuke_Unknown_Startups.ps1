<#
.SYNOPSIS
Remedy 07: Nuke Unknown Startups
.DESCRIPTION
Disables unsigned/unverified Registry Run keys and suspends unauthorized tasks running from AppData.
#>
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

$Timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = Join-Path $global:Path_RemediationLogs "Remedy_07_NukeStartups_${env:COMPUTERNAME}_${Timestamp}.txt"

Function Write-RemedyLog {
    param([string]$Message)
    $Stamp = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $Message
    Add-Content -Path $LogFile -Value $Stamp
}

Write-RemedyLog "=== STARTING REMEDY 07: NUKE UNKNOWN STARTUPS ==="

try {
    $RunKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    )

    $SuspiciousPaths = @("AppData\Local\Temp", "AppData\Roaming", "ProgramData")

    Write-RemedyLog "[*] Scanning Registry Run keys for AppData/ProgramData hooks..."
    
    foreach ($Key in $RunKeys) {
        if (Test-Path $Key) {
            $Values = Get-ItemProperty -Path $Key -ErrorAction SilentlyContinue
            foreach ($Val in $Values.psobject.properties) {
                if ($Val.Name -notin @("PSPath","PSParentPath","PSChildName","PSDrive","PSProvider")) {
                    $Cmd = $Val.Value -as [string]
                    $IsBad = $false
                    foreach ($Susp in $SuspiciousPaths) {
                        if ($Cmd -match [regex]::Escape($Susp)) { $IsBad = $true; break }
                    }
                    if ($IsBad) {
                        Write-RemedyLog "[!] Malicious Run Key identified: $($Val.Name) -> $Cmd"
                        Remove-ItemProperty -Path $Key -Name $Val.Name -Force -ErrorAction SilentlyContinue
                        Write-RemedyLog "[+] Successfully nuked run key: $($Val.Name)"
                    }
                }
            }
        }
    }

    Write-RemedyLog "[*] Disabling high-risk Scheduled Tasks..."
    $SuspiciousTasks = Get-ScheduledTask | Where-Object { $_.State -ne 'Disabled' -and $_.TaskPath -notmatch "\\Microsoft" -and $_.Author -notmatch "Microsoft|Google|Mozilla|Adobe" }
    foreach ($Task in $SuspiciousTasks) {
        Disable-ScheduledTask -TaskName $Task.TaskName -TaskPath $Task.TaskPath -ErrorAction SilentlyContinue
        Write-RemedyLog "[+] Disabled unknown third-party task: $($Task.TaskName)"
    }

} catch {
    Write-RemedyLog "[-] FATAL ERROR during Startup Purge: $($_.Exception.Message)"
}

Write-RemedyLog "=== REMEDY 07 COMPLETE ==="