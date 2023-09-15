$ErrorActionPreference = 'Stop'

$KMSServer = "{{ kms_server }}"

#----------End of variables, Start of Script----------#

{{ extra_activation_command }}

if ((Get-WmiObject -class Win32_OperatingSystem).Caption -like "Microsoft Windows 11*") {

    Write-Host "Setting the correct key KMS for Windows 11..."
    cscript.exe $env:windir\system32\slmgr.vbs /ipk NPPR9-FWDCX-D2C8J-H872K-2YT43

}

Write-Host "Activating Windows..."
cscript.exe $env:windir\system32\slmgr.vbs /skms $KMSServer
cscript.exe $env:windir\system32\slmgr.vbs /ato

# Activation Office if required
$OfficeActivator = Get-ChildItem "C:\Program Files\Microsoft Office" -Recurse  | Where-object Name -eq OSPP.vbs | Select-Object -ExpandProperty FullName

if ($null -ne $OfficeActivator) {

    Write-Host "Activating Microsoft Office..."
    cscript.exe $OfficeActivator /act

}