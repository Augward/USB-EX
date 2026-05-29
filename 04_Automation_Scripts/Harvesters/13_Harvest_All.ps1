Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force
Write-Host "Initiating Omnibus God-Object Harvester..." -ForegroundColor Red

# Suppress console output of child scripts, execute them and capture their custom objects
$Scripts = @(
    "01_Harvest_Hardware.ps1", "02_Harvest_Network.ps1", "03_Harvest_Users.ps1",
    "04_Harvest_Software.ps1", "05_Harvest_Connections.ps1", "06_Harvest_Security.ps1",
    "07_Harvest_Startups.ps1", "08_Harvest_Logs.ps1", "09_Harvest_USBs.ps1",
    "10_Harvest_Anomalies.ps1", "11_Harvest_Mappings.ps1", "12_Harvest_Configs.ps1"
)

$OmnibusData = [ordered]@{}

foreach ($Script in $Scripts) {
    $ScriptPath = Join-Path $PSScriptRoot $Script
    if (Test-Path $ScriptPath) {
        Write-Host " -> Extracting via $Script..." -ForegroundColor Yellow
        
        # Override the export function temporarily for this session to capture payload
        Function Export-USBEXData {
            param($AuditType, $DataPayload, $ReturnObjectInstead)
            return @{ $AuditType = $DataPayload }
        }

        $Result = . $ScriptPath
        foreach ($Key in $Result.Keys) {
            $OmnibusData[$Key] = $Result[$Key]
        }
    } else {
        Write-Host " -> [WARN] Could not locate $Script" -ForegroundColor DarkRed
    }
}

# Restore original Export function
Remove-Item Function:\Export-USBEXData
Import-Module "$PSScriptRoot\..\USBEX_Core.psm1" -Force

# Export the massive nested object
Export-USBEXData -AuditType "0mnibus" -DataPayload $OmnibusData
Write-Host "Omnibus Harvester Complete." -ForegroundColor Green