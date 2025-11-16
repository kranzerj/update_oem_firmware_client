Start-Transcript -LiteralPath "C:\Lenovo_Autoupdate\lsuclient_$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Führe den Update-Befehl aus, um sicherzustellen, dass das Modul aktuell ist
Write-Host "Stelle sicher, dass LSUClient auf dem neuesten Stand ist..." -ForegroundColor Blue
Update-Module -Name LSUClient

Write-Host "LSUClient Modul ist jetzt aktuell." -ForegroundColor Green


$updates = Get-LSUpdate -Verbose
Write-Host "$($updates.Count) updates found"

$i = 1
foreach ($update in $updates) {
    Write-Host "Downloading update $i of $($updates.Count): $($update.Title)"
    Save-LSUpdate -Package $update -Verbose
    $i++
}

$i = 1
foreach ($update in $updates) {
    Write-Host "Installing update $i of $($updates.Count): $($update.Title)"
    Install-LSUpdate -Package $update -Verbose
    $i++
}

Stop-Transcript