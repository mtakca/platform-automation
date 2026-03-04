# Windows Initialization - Footer
Write-Output "=== Windows VM Initialization Completed at $(Get-Date) ==="
Stop-Transcript

# Reboot to apply hostname change
Restart-Computer -Force
