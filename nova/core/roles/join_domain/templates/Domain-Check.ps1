$ErrorActionPreference = "Stop"

$DomainJoined = (Get-WmiObject win32_computersystem).partofdomain

if ($DomainJoined -eq $true) {

    nltest /sc_verify:{{ ad_domain_name }}

} else {

    Write-Host "WORKGROUP"
}