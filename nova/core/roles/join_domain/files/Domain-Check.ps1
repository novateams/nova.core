###
$ErrorActionPreference = "Stop"

$DomainJoined = (Get-WmiObject win32_computersystem).partofdomain

if ($DomainJoined -eq $true) {

    if (((Get-ComputerInfo).OsProductType) -eq "WorkStation") {

        Restart-Service Netlogon # Only restarting for Workstations, because servers might have a lot of dependencies for this service
    }

    Test-ComputerSecureChannel

} else {

    Write-Host "WORKGROUP" # This is written so Ansible would have something to print out
}