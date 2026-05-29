Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting Endpoint Security Posture..." -ForegroundColor Cyan

$Bitlocker = Get-BitLockerVolume -ErrorAction SilentlyContinue | Select-Object MountPoint, VolumeStatus, EncryptionPercentage, ProtectionStatus
$Defender = Get-MpComputerStatus -ErrorAction SilentlyContinue | Select-Object AMServiceEnabled, AntispywareEnabled, RealTimeProtectionEnabled, AMProductVersion
$Firewall = Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction
$ThirdPartyAV = Get-CimInstance -Namespace root\SecurityCenter2 -ClassName AntiVirusProduct -ErrorAction SilentlyContinue | Select-Object displayName, productState

$UACMap = @{
    0 = "0 - UAC Disabled (Elevate without prompting)"
    1 = "1 - Prompt for credentials on secure desktop"
    2 = "2 - Prompt for consent on secure desktop"
    3 = "3 - Prompt for credentials (Non-secure desktop)"
    4 = "4 - Prompt for consent (Non-secure desktop)"
    5 = "5 - Prompt for consent for non-Windows binaries (Default)"
}
$UACRaw = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -ErrorAction SilentlyContinue).ConsentPromptBehaviorAdmin
$UACLevel = if ($UACMap.ContainsKey($UACRaw)) { $UACMap[$UACRaw] } else { "$UACRaw - Unknown" }

$Data = [ordered]@{
    BitLockerStatus = $Bitlocker
    WindowsDefender = $Defender
    FirewallProfiles = $Firewall
    ThirdPartyAV = $ThirdPartyAV
    UACRegistryLevel = $UACLevel
}

Export-USBEXData -AuditType "Security" -DataPayload $Data