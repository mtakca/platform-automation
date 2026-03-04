# Windows Initialization Script - Header
$LogFile = "C:\Windows\Temp\vm-init.log"
Start-Transcript -Path $LogFile -Append

Write-Output "=== Windows VM Initialization Started at $(Get-Date) ==="
