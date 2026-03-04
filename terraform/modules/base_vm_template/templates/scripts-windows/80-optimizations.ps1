# 8. Production Optimizations

# Timezone Configuration
Write-Output "Setting timezone to Turkey Standard Time..."
Set-TimeZone -Id "Turkey Standard Time" -ErrorAction SilentlyContinue

# PowerShell Execution Policy
Write-Output "Setting PowerShell execution policy..."
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Windows Update Automation
Write-Output "Configuring Windows Update..."
Set-Service -Name wuauserv -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service -Name wuauserv -ErrorAction SilentlyContinue
try {
    $AutoUpdate = (New-Object -ComObject Microsoft.Update.AutoUpdate).Settings
    $AutoUpdate.NotificationLevel = 4  # Auto download and install
    $AutoUpdate.Save()
} catch {
    Write-Output "Windows Update configuration skipped (may require reboot)"
}

# Event Log Retention
Write-Output "Configuring Event Log retention..."
wevtutil sl Application /ms:104857600  # 100MB
wevtutil sl Security /ms:104857600
wevtutil sl System /ms:104857600

# Performance Tuning
Write-Output "Disabling unnecessary services..."
Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue  # Telemetry
Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue  # WAP Push
Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue

# PowerShell Logging (Audit)
Write-Output "Enabling PowerShell script block logging..."
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
New-Item -Path $RegPath -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $RegPath -Name "EnableScriptBlockLogging" -Value 1 -ErrorAction SilentlyContinue

# Network Optimization (WSUS)
Write-Output "Optimizing network settings..."
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global chimney=enabled

# SSD Optimization (TRIM)
Write-Output "Enabling TRIM for SSD..."
fsutil behavior set DisableDeleteNotify 0
