Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Harvesting Environment Variables & Hosts File..." -ForegroundColor Cyan

$HostsPath = "$env:windir\System32\drivers\etc\hosts"
$HostsContent = @()

try {
    if (Test-Path $HostsPath) {
        # Using native .NET to instantly read the file, bypassing AV pipeline locks
        $RawLines = [System.IO.File]::ReadAllLines($HostsPath)
        
        foreach ($Line in $RawLines) {
            # Filter out blank lines and comments
            if (-not [string]::IsNullOrWhiteSpace($Line) -and $Line -notmatch "^\s*#") {
                $HostsContent += $Line.Trim()
            }
        }

        if ($HostsContent.Count -eq 0) { 
            $HostsContent = @("Default (No custom routing)") 
        }
    } else {
        $HostsContent = @("Hosts file not found.")
    }
} catch {
    # If AV completely blocks read access, log it instead of hanging
    $HostsContent = @("Error reading hosts file. Access denied or locked by Antivirus.")
}

# Grabs System and User Environment Variables (PATH variables)
$EnvVars = Get-ChildItem Env: | Select-Object Name, Value

$Data = [ordered]@{
    ActiveHostsFileEntries = $HostsContent
    EnvironmentVariables = $EnvVars
}

Export-USBEXData -AuditType "Configs" -DataPayload $Data