# download-script.ps1

$taskName   = "DownloadPDFTask"
$scriptPath = "C:\DownloadPDF.ps1"
$url        = "https://teststract4352.blob.core.windows.net/files/US8678321.pdf"
$dest       = "C:\US8678321.pdf"
$logPath    = "C:\DownloadLog.txt"

# Ensure destination directory exists
if (-not (Test-Path "C:\")) {
    New-Item -Path "C:\" -ItemType Directory -Force
}

# Remove old scheduled task if it exists
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Write the script that downloads the PDF
@"
Invoke-WebRequest -Uri '$url' -OutFile '$dest' -UseBasicParsing
"@ | Out-File -FilePath $scriptPath -Encoding ASCII -Force

# Define action and trigger
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
          -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

$trigger = New-ScheduledTaskTrigger -Once `
           -At (Get-Date).AddMinutes(1) `
           -RepetitionInterval (New-TimeSpan -Minutes 5) `
           -RepetitionDuration ([TimeSpan]::FromDays(365))

# Register the task to run as SYSTEM
Register-ScheduledTask -TaskName $taskName `
                       -Action $action `
                       -Trigger $trigger `
                       -RunLevel Highest `
                       -User "SYSTEM" `
                       -Force

# Log task creation for debugging
"$((Get-Date).ToString()) - Task '$taskName' created for URL: $url" | Out-File $logPath -Append
