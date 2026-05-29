Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting User Accounts & Access Logs..." -ForegroundColor Cyan

$SecurityLogs = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=@(4624, 4625, 4634)} -MaxEvents 2000 -ErrorAction SilentlyContinue | 
    Select-Object TimeCreated, Id, @{N="Action";E={if($_.Id -eq 4624){"Logon"}elseif($_.Id -eq 4625){"Failed Logon"}else{"Logoff"}}}, @{N="Account";E={$_.Properties[5].Value}} |
    Where-Object { $_.Account -notmatch "SYSTEM|NETWORK SERVICE|LOCAL SERVICE|UMFD-|DWM-|ANONYMOUS" -and $_.Account -ne "$env:COMPUTERNAME$" -and $_.Account -ne $null } | 
    Select-Object -First 50

$Data = [ordered]@{
    LocalUsers = Get-LocalUser | Select-Object Name, Enabled, PasswordRequired, PasswordLastSet, PasswordExpires, LastLogon, Description
    AdminGroup = Get-LocalGroupMember -Group "Administrators" | Select-Object Name, PrincipalSource
    RecentHumanAuthEvents = $SecurityLogs
}

Export-USBEXData -AuditType "Users" -DataPayload $Data