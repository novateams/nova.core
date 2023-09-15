$ErrorActionPreference = 'Stop'

$AllUserProfiles = Get-ChildItem C:\Users | Select-Object -ExpandProperty Name

#----------End of variables, Start of Script----------#

# Looking up all profiles
foreach ($ProfileName in $AllUserProfiles) {

    # Cleaning up GT & Admin profiles
    if ($ProfileName -like "{{ gt_username }}" -or $ProfileName -like "{{ admin_account }}") {

        Write-Host "Cleaning up $ProfileName's profile"

        if ((Test-Path "C:\Users\$ProfileName\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\*") -eq $true) {Remove-Item "C:\Users\$ProfileName\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\*" -Recurse -Force}
        if ((Test-Path "C:\Users\$ProfileName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\*") -eq $true) {Remove-Item "C:\Users\$ProfileName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\*" -Recurse -Force}
        if ((Test-Path "C:\Users\$ProfileName\AppData\Local\AppData\Local\Temp\*") -eq $true) {Remove-Item "C:\Users\$ProfileName\AppData\Local\AppData\Local\Temp\*" -Recurse -Force}

    }

}

if ((Test-Path "C:\ProgramData\chocolatey\logs\*") -eq $true) {Remove-Item "C:\ProgramData\chocolatey\logs\*" -Recurse -Force}
if ((Test-Path "C:\ExchangeSetupLogs") -eq $true) {Remove-Item "C:\ExchangeSetupLogs" -Recurse -Force}
if ((Test-Path "C:\root") -eq $true) {Remove-Item "C:\root" -Recurse -Force}
if ((Test-Path "C:\BitlockerActiveMonitoringLogs") -eq $true) {Remove-Item "C:\BitlockerActiveMonitoringLogs" -Force}
if ((Test-Path "C:\Windows\Prefetch\*") -eq $true) {Get-ChildItem "C:\Windows\Prefetch\" -Recurse | Where-Object Name -NotLike "ReadyBoot*" | Remove-Item -Force}
if ((Test-Path "C:\Windows\System32\Sysprep\Unattend.xml") -eq $true) {Remove-Item "C:\Windows\System32\Sysprep\Unattend.xml" -Force}

# Packer artifacts
if ((Get-ScheduledTask | Select-Object -ExpandProperty TaskName) -like "packer*"){Unregister-ScheduledTask -TaskName "packer*" -Confirm:$false}

# Temp cleanup
Remove-Item C:\Windows\Temp\* -Recurse -Force -ErrorAction SilentlyContinue

# Event log cleanup
wevtutil el  | ForEach-Object {if ($_ -notlike "Microsoft-Windows-LiveId*") {wevtutil cl "$_"}}
