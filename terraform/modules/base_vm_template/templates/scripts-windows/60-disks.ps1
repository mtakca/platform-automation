# 6. Data Disk Mounting
Write-Output "Mounting data disks..."
Get-Disk | Where-Object { $_.PartitionStyle -eq 'RAW' } | ForEach-Object {
    $DiskNumber = $_.Number
    Write-Output "Initializing Disk $DiskNumber..."
    
    # Initialize disk
    Initialize-Disk -Number $DiskNumber -PartitionStyle GPT -ErrorAction SilentlyContinue
    
    # Create partition and format
    $Partition = New-Partition -DiskNumber $DiskNumber -UseMaximumSize -AssignDriveLetter
    $DriveLetter = $Partition.DriveLetter
    
    Format-Volume -DriveLetter $DriveLetter -FileSystem NTFS -NewFileSystemLabel "Data$DiskNumber" -Confirm:$false
    
    Write-Output "Disk $DiskNumber mounted as ${DriveLetter}:\"
}
