Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting Live Sockets & Process Mappings..." -ForegroundColor Cyan

$TCP = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -and $_.RemoteAddress -notmatch "^127\.|^0\.|^::" } | 
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}

$UDP = Get-NetUDPEndpoint | Where-Object { $_.LocalAddress -notmatch "^127\.|^0\.|^::" } | 
    Select-Object LocalAddress, LocalPort, @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}

$Data = [ordered]@{
    Active_TCP_Outbound = $TCP
    Active_UDP_Endpoints = $UDP
}

Export-USBEXData -AuditType "Connections" -DataPayload $Data