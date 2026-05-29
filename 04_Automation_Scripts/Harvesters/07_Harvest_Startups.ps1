Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting Startup Hooks & Ghost Processes..." -ForegroundColor Cyan

# Bypass broken WMI Win32_StartupCommand by reading the Registry directly
$RunKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
)

$StartupReg = @()
foreach ($Key in $RunKeys) {
    $Values = Get-ItemProperty -Path $Key -ErrorAction SilentlyContinue
    foreach ($Val in $Values.psobject.properties) {
        if ($Val.Name -notin @("PSPath","PSParentPath","PSChildName","PSDrive","PSProvider")) {
            $StartupReg += [pscustomobject]@{ Name = $Val.Name; Command = $Val.Value; Root = $Key }
        }
    }
}

# Filter out native Microsoft tasks to expose third-party software/malware
$ScheduledTasks = Get-ScheduledTask | Where-Object { $_.State -ne 'Disabled' -and $_.TaskPath -notmatch "\\Microsoft\\" } | Select-Object TaskName, TaskPath, State, Author
$ActiveServices = Get-Service | Where-Object Status -eq 'Running' | Select-Object Name, DisplayName, StartType

$Data = [ordered]@{
    RegistryRunKeys = $StartupReg
    ThirdPartyScheduledTasks = $ScheduledTasks
    RunningServices = $ActiveServices
}

Export-USBEXData -AuditType "Startups" -DataPayload $Data