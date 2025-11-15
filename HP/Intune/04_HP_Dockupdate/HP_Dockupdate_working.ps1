Start-Transcript -Path "C:\hp\HPDockFirmware\Firmwareupdate.log" -Append

# Make parsing robust
$ErrorActionPreference = 'Stop'

# Target path for the PowerShell module
$targetPath = 'C:\Program Files\WindowsPowerShell\Modules\HP.Docks'

# Check if module is installed
$module = Get-Module -ListAvailable -Name 'HP.Docks' | Sort-Object Version -Descending | Select-Object -First 1

# Decide if we need to copy: missing or version <= 1.8.1
$needsCopy = $false
if (-not $module) {
    Write-Host 'Module "HP.Docks" not found.'
    $needsCopy = $true
}
elseif ([version]$module.Version -le [version]'1.8.1') {
    Write-Host ('Module "HP.Docks" found with version {0}, which is too low.' -f $module.Version)
    $needsCopy = $true
}
else {
    Write-Host ('Module "HP.Docks" is sufficient: version {0}.' -f $module.Version)
}

# Copy if needed
if ($needsCopy) {
    $sourcePath = "C:\hp\HPDockFirmware\HP.Docks"

    if (Test-Path $sourcePath) {
        Write-Host ('Copying "{0}" to "{1}" ...' -f $sourcePath, $targetPath)
        Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
        Write-Host 'Copy completed.'
    }
    else {
        Write-Error ('Source folder not found: "{0}"' -f $sourcePath)
    }
}

# Check if a dock is attached and update firmware if so
try {
    $dock = Get-HPDock -AutoInstallWmiProvider
    if ($dock) {
	cd C:\hp\HPDockFirmware
        Write-Host ('Dock detected: {0}' -f $dock.Name)
        Write-Host 'Starting firmware update...'
        Update-HPDockFirmware -Experience NonInteractive
        Write-Host 'Firmware update finished or not necessary'
    }
    else {
        Write-Host 'No dock attached - skipping firmware update.'
    }
}
catch {
    Write-Error ('Error while checking dock or updating firmware: {0}' -f $_)
}


Stop-Transcript
