$ErrorActionPreference = 'Stop'

if (Test-Path "C:\ProgramData\ssh\.regenerated") {

    Write-Host "Host keys have already been regenerated."

} else {

    Remove-Item -Force -Recurse "C:\ProgramData\ssh\ssh_host_*_key*"
    Restart-Service sshd
    New-Item -ItemType File -Path "C:\ProgramData\ssh\.regenerated"

}