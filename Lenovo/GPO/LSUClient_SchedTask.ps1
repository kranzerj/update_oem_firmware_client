Start-Transcript -LiteralPath "C:\Lenovo_Autoupdate\startupscript_$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# ---------------------------
# Alte Logs löschen (älter als 14 Tage)
# ---------------------------
Get-ChildItem -Path "C:\Lenovo_Autoupdate\" -Filter "startupscript*.log" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-14) } | 
    Remove-Item -Force

# ---------------------------
# LSUClient Modul prüfen und installieren/aktualisieren
# ---------------------------
$moduleName = 'LSUClient'

if (-not (Get-Module -ListAvailable -Name $moduleName)) {
    Write-Host "$moduleName Modul ist nicht installiert. Installation wird durchgeführt..." -ForegroundColor Green
    Install-PackageProvider -Name NuGet -Force -ForceBootstrap -Scope AllUsers
    Install-Module -Name $moduleName -Force -AllowClobber
    Write-Host "$moduleName Modul wurde erfolgreich installiert." -ForegroundColor Green
} else {
    Write-Host "$moduleName Modul ist bereits installiert." -ForegroundColor Yellow
}

# ---------------------------
# Überprüfen, ob Task existiert
# ---------------------------
$taskName = "LenovoClient-Autoupdate"
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }

if ($taskExists) {
    Write-Host "Der geplante Task '$taskName' existiert bereits. Es ist keine Aktion erforderlich." -ForegroundColor Yellow
} else {
    Write-Host "Der geplante Task '$taskName' existiert nicht. Erstelle den Task..." -ForegroundColor Green

    # ---------------------------
    # Betriebssystemalter prüfen
    # ---------------------------
    $osInstallDate = (Get-CimInstance Win32_OperatingSystem).InstallDate
    $oneMonthAgo = (Get-Date).AddMonths(-1)

    if ($osInstallDate -gt $oneMonthAgo) {
        Write-Host "OS wurde vor weniger als einem Monat installiert. Task startet ab morgen." -ForegroundColor Green
        $firstDate = (Get-Date).AddDays(1).Date
    } else {
        # Zufälliges Startdatum innerhalb der nächsten 40 Tage
        $tomorrow = (Get-Date).AddDays(1).Date
        $fortyDaysLater = (Get-Date).AddDays(40).Date
        $daysRange = ($fortyDaysLater - $tomorrow).Days

        do {
            $randomDayOffset = Get-Random -Minimum 0 -Maximum $daysRange
            $randomDate = $tomorrow.AddDays($randomDayOffset)
            $randomWeekday = $randomDate.DayOfWeek
        } while ($randomWeekday -eq 'Saturday' -or $randomWeekday -eq 'Sunday')

        $firstDate = $randomDate
    }

    # ---------------------------
    # Drei aufeinanderfolgende Werktage berechnen
    # ---------------------------
    function Get-NextWorkday([datetime]$date) {
        while ($date.DayOfWeek -eq 'Saturday' -or $date.DayOfWeek -eq 'Sunday') {
            $date = $date.AddDays(1)
        }
        return $date
    }

    $firstDay = Get-NextWorkday $firstDate
    $secondDay = Get-NextWorkday $firstDay.AddDays(1)
    $thirdDay = Get-NextWorkday $secondDay.AddDays(1)

    # Setze Uhrzeit auf 09:00 Uhr
    $startTime = 9
    $firstDateTime = $firstDay.AddHours($startTime)
    $secondDateTime = $secondDay.AddHours($startTime)
    $thirdDateTime = $thirdDay.AddHours($startTime)

    # ---------------------------
    # Task-Parameter
    # ---------------------------
    $scriptPath = "C:\Lenovo_Autoupdate\LSUpdate.ps1"  # Pfad zum Skript
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

    # Drei Trigger für die drei Tage
    $trigger1 = New-ScheduledTaskTrigger -Daily -At $firstDateTime -DaysInterval 90
    $trigger2 = New-ScheduledTaskTrigger -Daily -At $secondDateTime -DaysInterval 90
    $trigger3 = New-ScheduledTaskTrigger -Daily -At $thirdDateTime -DaysInterval 90

    # Task-Einstellungen und SYSTEM-User
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries
    $principal = New-ScheduledTaskPrincipal -UserId "System" -LogonType ServiceAccount -RunLevel Highest

    # Task registrieren
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger1, $trigger2, $trigger3 -Settings $settings -Principal $principal -Force

    Write-Host "Der geplante Task '$taskName' wurde erfolgreich für drei aufeinanderfolgende Arbeitstage erstellt." -ForegroundColor Green
}

Stop-Transcript
