# download-script.ps1

$taskName   = "DownloadPDFTask"
$scriptPath = "C:\DownloadPDF.ps1"
$url        = "https://teststract4352.blob.core.windows.net/files/US8678321.pdf"
$dest       = "C:\US8678321.pdf"

# 1. Write the script that downloads the PDF
@"
Invoke-WebRequest -Uri '$url' -OutFile '$dest' -UseBasicParsing
"@ | Out-File -FilePath $scriptPath -Encoding ASCII

# 2. Define action and trigger for scheduled task
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
          -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

$trigger = New-ScheduledTaskTrigger -Once `
           -At (Get-Date).AddMinutes(1) `
           -RepetitionInterval (New-TimeSpan -Minutes 5) `
           -RepetitionDuration ([TimeSpan]::FromDays(365))

# 3. Register the scheduled task
Register-ScheduledTask -TaskName $taskName `
                       -Action $action `
                       -Trigger $trigger `
                       -RunLevel Highest `
                       -User "SYSTEM" `
                       -Force

# 4. Optional local log (for debugging)
"$((Get-Date).ToString()) - Task '$taskName' created." | Out-File "C:\DownloadLog.txt" -Append
