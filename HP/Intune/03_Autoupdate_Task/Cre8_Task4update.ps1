##### create Task ######

Copy-Item ".\HPIA_update.ps1" -Destination "C:\Program Files\HPImageAssistant"

# Define task parameters
$taskName = "HPIA Update"
$scriptPath = "C:\Program Files\HPImageAssistant\HPIA_update.ps1"



#zufälliger Tag


# Setze das Startdatum auf morgen
$tomorrow = (Get-Date).AddDays(1).Date

# Setze das Enddatum auf drei Wochen später
$threeWeeksLater = (Get-Date).AddDays(21).Date

# Berechne die Anzahl der Tage zwischen morgen und drei Wochen später
$daysRange = ($threeWeeksLater - $tomorrow).Days

# Generiere eine zufällige Anzahl von Tagen im Bereich von morgen bis drei Wochen später
$randomDayOffset = Get-Random -Minimum 0 -Maximum $daysRange

# Bestimme das zufällige Datum
$randomDate = $tomorrow.AddDays($randomDayOffset)

# Hole den Wochentag des zufälligen Datums (0 = Sonntag, 1 = Montag, ..., 6 = Samstag)
$randomWeekday = (Get-Date $randomDate).DayOfWeek

# Wenn der zufällige Wochentag ein Samstag (6) oder Sonntag (0) ist, wähle einen neuen zufälligen Werktag
while ($randomWeekday -eq 0 -or $randomWeekday -eq 6) {
    # Generiere einen neuen zufälligen Tag im Bereich von morgen bis drei Wochen später
    $randomDayOffset = Get-Random -Minimum 0 -Maximum $daysRange
    $randomDate = $tomorrow.AddDays($randomDayOffset)
    $randomWeekday = (Get-Date $randomDate).DayOfWeek
}

# Setze die Uhrzeit auf 09:00 Uhr
$startDateTime = $randomDate.AddHours(9)




#




# Create the action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# Create a daily trigger, use repetition interval of 90 days 
$trigger = New-ScheduledTaskTrigger -Daily -At $startDateTime -DaysInterval 90

# Define settings with 'StartWhenAvailable'
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries

# Define principal to run as SYSTEM with highest privileges
$principal = New-ScheduledTaskPrincipal -UserId "System" -LogonType ServiceAccount -RunLevel Highest

# Register the task
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force
