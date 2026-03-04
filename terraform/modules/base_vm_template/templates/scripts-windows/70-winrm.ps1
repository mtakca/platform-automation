# 7. WinRM Configuration (for Ansible)
Write-Output "Configuring WinRM for Ansible..."
Enable-PSRemoting -Force -SkipNetworkProfileCheck
winrm quickconfig -q
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
