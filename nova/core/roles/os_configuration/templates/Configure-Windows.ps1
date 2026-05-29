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

{% if kms_server is ansible.builtin.truthy %}
$KMSServer = "{{ kms_server }}"

#----------End of variables, Start of Script----------#

{{ extra_activation_command }}

Write-Host "Activating Windows..."
cscript.exe $env:windir\system32\slmgr.vbs /skms $KMSServer
cscript.exe $env:windir\system32\slmgr.vbs /ato

# Activation Office if required
$OfficeActivator = Get-ChildItem "C:\Program Files\Microsoft Office" -Recurse  | Where-object Name -eq OSPP.vbs | Select-Object -ExpandProperty FullName

if ($null -ne $OfficeActivator) {

    Write-Host "Activating Microsoft Office..."
    cscript.exe $OfficeActivator /act

}
{% endif %}
