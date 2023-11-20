$ErrorActionPreference = 'Stop'

# Time
$TimeZone = "UTC"
Set-Service W32Time -StartupType Automatic
Start-Service W32Time
Set-TimeZone -Id $TimeZone

# Power
powercfg -change -monitor-timeout-ac 0
powercfg -change -standby-timeout-ac 0
powercfg -change -disk-timeout-ac 0
powercfg -change -hibernate-timeout-ac 0
powercfg -change -monitor-timeout-dc 0
powercfg -change -standby-timeout-dc 0
powercfg -change -disk-timeout-dc 0
powercfg -change -hibernate-timeout-dc 0