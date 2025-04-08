$ErrorActionPreference = 'Stop'

if ($null -eq (Get-Content C:\ProgramData\ssh\ssh_host* | findstr.exe "system@")) {

    Remove-Item -Force -Recurse "C:\ProgramData\ssh\ssh_host_*_key*"
    ssh-keygen -A

} else {

    Write-Host "Skipping regeneration"

}