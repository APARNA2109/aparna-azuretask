# DownloadAndLog.ps1
$taskName   = "DownloadPDFTask"
$scriptPath = "C:\DownloadPDF.ps1"
$url        = "https://teststract4352.blob.core.windows.net/files/US8678321.pdf"
$dest       = "C:\US8678321.pdf"
$logFile    = "C:\DownloadLog.txt"

# 1.  Save the one‑line downloader script
@"
Invoke-WebRequest -Uri '$url' -OutFile '$dest' -UseBasicParsing
"@ | Out-File -FilePath $scriptPath -Encoding ASCII

# 2.  Register a task that runs every 5 min for 365 days (XML‑safe)
$action  = New-ScheduledTaskAction  -Execute "PowerShell.exe" `
           -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Once  `
           -At (Get-Date).AddMinutes(1)    `
           -RepetitionInterval (New-TimeSpan -Minutes 5) `
           -RepetitionDuration  ([TimeSpan]::FromDays(365))

Register-ScheduledTask -TaskName $taskName `
                       -Action   $action  `
                       -Trigger  $trigger `
                       -RunLevel Highest `
                       -User     "SYSTEM" `
                       -Force

# 3.  Basic local log (optional)
"$((Get-Date).ToString()) - Task registered." | Out-File $logFile -Append
