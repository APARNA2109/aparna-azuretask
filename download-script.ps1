$taskName = "DownloadPDFTask"
$scriptPath = "C:\DownloadPDF.ps1"
$url = "https://teststract4352.blob.core.windows.net/files/US8678321.pdf"
$destination = "C:\US8678321.pdf"

# Write the download script
@"
Invoke-WebRequest -Uri '$url' -OutFile '$destination'
"@ | Out-File -FilePath $scriptPath -Encoding ASCII

# Create the scheduled task
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue)
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -RunLevel Highest -Force
