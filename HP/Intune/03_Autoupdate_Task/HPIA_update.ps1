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
