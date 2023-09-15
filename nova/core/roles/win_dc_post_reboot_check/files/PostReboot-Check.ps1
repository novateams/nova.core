
Get-EventLog -LogName 'Active Directory Web Services'

if ($null -eq $Error) {
    
# Getting the date after last reboot
$Date = Get-EventLog -LogName 'System' | Where-Object InstanceID -EQ 2147489654 | Select-Object -First 1 | Select-Object -ExpandProperty TimeGenerated

if ($null -eq $Date) {

    # Getting the random latest timestamp if last reboot event doesn't exist
    $RealDate = Get-EventLog -LogName 'System' | Select-Object -First 1 | Select-Object -ExpandProperty TimeGenerated

} else {

    $RealDate = $Date
}

# Waiting until ADWS service is started
do {Start-Sleep -Seconds 5} until ((Get-EventLog -LogName 'Active Directory Web Services' -After $RealDate | Where-Object InstanceID -EQ 1073743024 | Select-Object -ExpandProperty InstanceID -Unique) -eq 1073743024)

} else {
    
    Write-Host "ADWS is most likely running..."
}