Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting Installed Software & Licensing..." -ForegroundColor Cyan

$UninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$InstalledApps = Get-ItemProperty $UninstallKeys -ErrorAction SilentlyContinue | 
    Where-Object { $_.DisplayName -and $_.DisplayName -ne $null } | 
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation |
    Sort-Object DisplayName -Unique

$ProductKey = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey

$Data = [ordered]@{
    OSKey = if ($ProductKey) { $ProductKey } else { "Not Embedded in BIOS/UEFI" }
    Hotfixes = Get-HotFix | Select-Object HotFixID, Description, InstalledOn, InstalledBy
    InstalledSoftware = $InstalledApps
}

Export-USBEXData -AuditType "Software" -DataPayload $Data