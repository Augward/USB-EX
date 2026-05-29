Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting Network Shares & Mapped Drives..." -ForegroundColor Cyan

# Grabs folders on this computer being shared with the local network
$LocalShares = Get-SmbShare -ErrorAction SilentlyContinue | Select-Object Name, Path, Description, ShareState

# Grabs mapped network drives (DriveType 4 indicates a Network Drive)
$MappedDrives = Get-CimInstance Win32_LogicalDisk -ErrorAction SilentlyContinue | 
    Where-Object { $_.DriveType -eq 4 } | 
    Select-Object DeviceID, ProviderName, VolumeName

$Data = [ordered]@{
    LocalSMBSharedFolders = $LocalShares
    MappedNetworkDrives = $MappedDrives
}

Export-USBEXData -AuditType "Mappings" -DataPayload $Data