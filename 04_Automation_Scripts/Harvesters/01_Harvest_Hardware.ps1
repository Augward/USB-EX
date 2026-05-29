Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting Deep Hardware Specifications..." -ForegroundColor Cyan

$Battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object Name, EstimatedChargeRemaining, DesignCapacity, FullChargeCapacity, BatteryStatus
if (-not $Battery) { $Battery = "Desktop / No Battery Detected" }

$SMARTHealth = Get-PhysicalDisk -ErrorAction SilentlyContinue | Select-Object FriendlyName, SerialNumber, MediaType, HealthStatus, OperationalStatus

$Data = [ordered]@{
    System = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model, SystemType, TotalPhysicalMemory, Domain, Name
    CPU = Get-CimInstance Win32_Processor | Select-Object Name, Architecture, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, L2CacheSize, L3CacheSize
    Motherboard = Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product, SerialNumber, Version
    RAM = Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, PartNumber, Capacity, Speed, MemoryType, FormFactor, DeviceLocator
    GPU = Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, AdapterRAM, VideoProcessor, CurrentRefreshRate
    Storage = Get-CimInstance Win32_DiskDrive | Select-Object Model, InterfaceType, Size, Partitions, Status, SerialNumber
    StorageHealth = $SMARTHealth
    Partitions = Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, VolumeName, FileSystem, Size, FreeSpace, DriveType
    BIOS = Get-CimInstance Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate, SerialNumber
    Battery = $Battery
    Monitors = Get-CimInstance WmiMonitorID -Namespace root\wmi -ErrorAction SilentlyContinue | Select-Object @{N="Manufacturer";E={[System.Text.Encoding]::ASCII.GetString($_.ManufacturerName -ne 0)}}, @{N="Model";E={[System.Text.Encoding]::ASCII.GetString($_.UserFriendlyName -ne 0)}}
}

Export-USBEXData -AuditType "Hardware" -DataPayload $Data