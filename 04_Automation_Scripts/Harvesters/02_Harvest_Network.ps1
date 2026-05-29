Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting Network Topology & Profiles..." -ForegroundColor Cyan

$WlanProfiles = @()
try {
    $Profiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$_.Matches.Groups[1].Value.Trim()}
    foreach ($Profile in $Profiles) {
        $Key = (netsh wlan show profile name="$Profile" key=clear) | Select-String "Key Content" | %{$_.Line.Split(":")[1].Trim()}
        if (-not $Key) { $Key = "Open/None" }
        $WlanProfiles += [pscustomobject]@{ SSID = $Profile; Key = $Key }
    }
} catch { $WlanProfiles = "WLAN Service not running." }

$Data = [ordered]@{
    ActiveAdapters = Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object Name, InterfaceDescription, MacAddress, LinkSpeed
    IPConfig = Get-NetIPAddress -AddressFamily IPv4 | Where-Object InterfaceAlias -notmatch "Loopback" | Select-Object InterfaceAlias, IPAddress, PrefixLength
    DHCPLeases = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object IPEnabled -eq $true | Select-Object Description, DHCPEnabled, DHCPServer, DHCPLeaseObtained, DHCPLeaseExpires
    RoutingTable = Get-NetRoute | Where-Object { $_.DestinationPrefix -notmatch "^127\.|^ff|^::1|^224\." } | Select-Object DestinationPrefix, NextHop, RouteMetric, InterfaceAlias
    ARPCache = Get-NetNeighbor -AddressFamily IPv4 | Where-Object { $_.State -ne 'Unreachable' -and $_.IPAddress -notmatch "^127\.|^224\." } | Select-Object IPAddress, LinkLayerAddress, State, InterfaceAlias
    DNSCache = Get-DnsClientCache | Select-Object Entry, Data | Sort-Object Entry -Unique
    WLANProfiles = $WlanProfiles
}

Export-USBEXData -AuditType "Network" -DataPayload $Data