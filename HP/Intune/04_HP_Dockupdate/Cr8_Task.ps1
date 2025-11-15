# Name der Tasks
$hpiaTaskName = "HPIA Update"
$dockTaskName = "HP Thunderbolt Dock Update"

##### create Task ######

New-Item -Path "C:\hp\HPDockFirmware" -ItemType Directory

Copy-Item ".\HP_Dockupdate_working.ps1" -Destination "C:\hp\HPDockFirmware"
Copy-Item ".\HP.Docks\" -Destination "C:\hp\HPDockFirmware" -Recurse -Force

# Define task parameters
$scriptPath = "C:\hp\HPDockFirmware\HP_Dockupdate_working.ps1"


# Taskdefinition von HPIA laden
$hpiaTask = Get-ScheduledTask -TaskName $hpiaTaskName -ErrorAction Stop
$hpiaInfo = Get-ScheduledTaskInfo -TaskName $hpiaTaskName

if (-not $hpiaInfo.NextRunTime) {
    Write-Error "Der Task '$hpiaTaskName' hat keine geplante nächste Ausführung!"
    exit 1
}

# Nächste Ausführung von HPIA ermitteln
$hpiaNextRun = $hpiaInfo.NextRunTime

# 7 Tage vorher berechnen
$dockRunTime = $hpiaNextRun.AddDays(-7)

# Falls das Datum in der Vergangenheit liegt, solange +1 Tag addieren bis es in der Zukunft ist
while ($dockRunTime -lt (Get-Date)) {
    $dockRunTime = $dockRunTime.AddDays(1)
}

# Uhrzeit fix auf 08:00 setzen
$dockRunTime = Get-Date $dockRunTime.Date -Hour 8 -Minute 0 -Second 0

Write-Output "HPIA läuft am: $hpiaNextRun"
Write-Output "Thunderbolt Dock Update wird geplant für: $dockRunTime"

# Aktion definieren
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# Trigger definieren
$trigger = New-ScheduledTaskTrigger -Daily -At $dockRunTime -DaysInterval 90

# Define settings with 'StartWhenAvailable'
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries

# Principal (als Systemkonto ausführen)
$principal = New-ScheduledTaskPrincipal -UserId "System" -LogonType ServiceAccount -RunLevel Highest

# Task registrieren (überschreibt, falls schon vorhanden)
Register-ScheduledTask -TaskName $dockTaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force

Write-Output "Task '$dockTaskName' wurde erstellt."
