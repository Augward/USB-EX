Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting Device Anomalies & Printers..." -ForegroundColor Cyan

# Grabs devices reporting errors (ConfigManagerErrorCode other than 0 = "Working properly")
$ProblemDevices = Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue | 
    Where-Object { $_.ConfigManagerErrorCode -ne 0 -and $_.ConfigManagerErrorCode -ne $null } | 
    Select-Object Name, Manufacturer, DeviceID, ConfigManagerErrorCode

# Grabs all local and network printers mapped to the machine
$Printers = Get-CimInstance Win32_Printer -ErrorAction SilentlyContinue | 
    Select-Object Name, DriverName, PortName, Default, Network, Shared

$Data = [ordered]@{
    ProblematicDevices_YellowBangs = $ProblemDevices
    InstalledPrinters = $Printers
}

Export-USBEXData -AuditType "Anomalies" -DataPayload $Data