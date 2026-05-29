Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting Historic USB Device Registry Logs..." -ForegroundColor Cyan

$USBSTORPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR"
$USBDump = @()

if (Test-Path $USBSTORPath) {
    $USBDevices = Get-ChildItem -Path $USBSTORPath
    foreach ($Device in $USBDevices) {
        $SubKeys = Get-ChildItem -Path $Device.PSPath
        foreach ($Key in $SubKeys) {
            $Details = Get-ItemProperty -Path $Key.PSPath -ErrorAction SilentlyContinue
            
            # Clean up obscure manufacturer text formatting
            $MfgClean = $Details.Mfg -replace "@disk.inf,%genmanufacturer%;\(Standard disk drives\)", "Standard USB Drive"
            $MfgClean = $MfgClean -replace "@disk.inf,%genmanufacturer%;", ""

            $USBDump += [pscustomobject]@{
                DeviceName = if ($Details.FriendlyName) { $Details.FriendlyName } else { $Details.DeviceDesc }
                Manufacturer = $MfgClean
            }
        }
    }
}

$CleanUSBs = $USBDump | Where-Object { $_.DeviceName -ne $null } | Sort-Object -Property DeviceName -Unique

$Data = [ordered]@{
    HistoricalUSBDevices = $CleanUSBs
}

Export-USBEXData -AuditType "USBs" -DataPayload $Data