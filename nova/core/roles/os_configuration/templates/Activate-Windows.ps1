$ErrorActionPreference = 'Stop'

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