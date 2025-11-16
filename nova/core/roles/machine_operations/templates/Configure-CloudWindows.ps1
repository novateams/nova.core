{% if infra_env == "aws" %}
<powershell>
{% endif %}
$ErrorActionPreference = 'Stop'

$LogPath = "C:\Windows\Temp\install.log"
$RemoteConnectivityHost = "google.com"
$OS = Get-WmiObject -Class Win32_OperatingSystem
$version = [version]$OS.Version
$SSHDownloadLink = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/10.0.0.0p2-Preview/OpenSSH-Win64-v10.0.0.0.msi"

#--------------------End of variables, Start of Script--------------------#

Start-Transcript -Path $LogPath

{% if infra_env == "aws" %}
Write-Host "Setting Administrator password"
$Password = "{{ template_password }}"
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $SecurePassword
{% endif %}

{% if infra_env == "azure" %}
Rename-LocalUser -Name "azureadmin" -NewName "Administrator"
{% endif %}

Write-Host "Checking that $RemoteConnectivityHost is reachable"
while($true) {
    $ping = Test-Connection -ComputerName $RemoteConnectivityHost -Count 1 -Quiet
    if($ping) {
        Write-Host "$RemoteConnectivityHost is reachable."
        break
    } else {
        Write-Host "Cannot reach $RemoteConnectivityHost. Retrying..."
        Start-Sleep -Seconds 3
    }
}

Write-Host "Setting PowerShell as default SSH shell"
reg add HKLM\Software\OpenSSH /v DefaultShell /t REG_SZ /d C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /f

if ($version.Major -ge 10) {

    Write-Host "Removing native OpenSSH Client"
    Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

}

Write-Host "Downloading and installing latest OpenSSH"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest -Uri $SSHDownloadLink -OutFile "C:\Windows\Temp\OpenSSH.msi"
msiexec /i "C:\Windows\Temp\OpenSSH.msi" /qn

while(-not (Get-NetFirewallRule | Where-object DisplayName -like "*OpenSSH*")) {
    Start-Sleep -Seconds 1
    Write-Host "Waiting until SSH firewall rule is created"
}

Write-Host "Allowing OpenSSH through firewall with all profiles"
Get-NetFirewallRule | Where-object DisplayName -like "*OpenSSH*" | Set-NetFirewallRule -Profile Any

Remove-item C:\Windows\Temp\OpenSSH.msi -Force

Stop-Transcript
{% if infra_env == "aws" %}
</powershell>
{% endif %}