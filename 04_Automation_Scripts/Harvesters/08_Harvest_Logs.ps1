Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting System Logs..." -ForegroundColor Cyan

$TimeLimit = (Get-Date).AddDays(-7)
$SysEvents = Get-WinEvent -FilterHashtable @{LogName='System','Application'; Level=1,2; StartTime=$TimeLimit} -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, Message
$BSODLogs = Get-WinEvent -FilterHashtable @{LogName='System'; Id=1001; StartTime=$TimeLimit} -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message

$Data = [ordered]@{
    RecentBSODs = $BSODLogs
    CriticalErrorLogs_7Days = $SysEvents
}

Export-USBEXData -AuditType "Logs" -DataPayload $Data