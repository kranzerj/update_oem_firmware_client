######01 install CMSL ######

# URL der Zielseite
$targetUrl = "https://www.hp.com/us-en/solutions/client-management-solutions/download.html"

# Setze den WebClient, um den Download zu starten
$webClient = New-Object System.Net.WebClient

# Lade den HTML-Inhalt der Zielseite herunter
$htmlContent = Invoke-WebRequest -Uri $targetUrl -UseBasicParsing

# Verwende Regex, um den Link zu extrahieren, der mit hp-cmsl endet und .exe enthält
$downloadUrl = [regex]::Match($htmlContent.Content, "https://.*?/hp-cmsl.*?\.exe").Value

# Prüfen, ob ein passender Link gefunden wurde
if ($downloadUrl) {
    Write-Host "Gefundener Download-Link: $downloadUrl"

    # Setze den Zielpfad, um die Datei zu speichern
    $downloadPath = "$env:Temp\hp-cmsl.exe"

    # Datei herunterladen
    try {
        Write-Host "Lade Datei herunter..."
        $webClient.DownloadFile($downloadUrl, $downloadPath)
        Write-Host "Download abgeschlossen."

        # Installiere die Datei mit den erforderlichen Parametern
        Write-Host "Installiere die heruntergeladene Datei..."
        Start-Process -FilePath $downloadPath -ArgumentList "/VERYSILENT", "/NORESTART", "/SUPPRESSMSGBOXES" -Wait

        Write-Host "Installation abgeschlossen."
    }
    catch {
        Write-Error "Fehler beim Herunterladen oder Installieren der Datei: $_"
    }
} else {
    Write-Error "Kein gültiger Link für hp-cmsl-Download gefunden."
}

######CMSL fertig ######

##### install Image Assiant ######
Import-Module HP.Softpaq
Install-HPImageAssistant -Extract "C:\Program Files\HPImageAssistant" -Quiet

######Image Assiant fertig ######

##### create PS Script ######

$scriptContent = @'
$HPIA_folder = "C:\Program Files\HPImageAssistant"
$HPIA_report = "$HPIA_folder\Report"
$HPIA_exe = "$HPIA_folder\HPImageAssistant.exe"

try{
    Start-Process $HPIA_exe -ArgumentList "/Operation:Analyze /Action:Install /Noninteractive /AutoCleanup /reportFolder:""$HPIA_report""" -Wait 
    $HPIA_analyze = Get-Content "$HPIA_report\*.json" | ConvertFrom-Json
    Write-Output "Installation completed: $($HPIA_analyze.HPIA.Recommendations)"
}catch{
    Write-Error $_.Exception
}
'@


Set-Content -Path "C:\Program Files\HPImageAssistant\HPIA_update.ps1" -Value $scriptContent

##### create Task ######


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


