$ErrorActionPreference = 'Stop'

if (Test-Path "C:\ProgramData\ssh\.regenerated") {
    Write-Host "Host keys have already been regenerated."
} else {
    Remove-Item -Force -Recurse "C:\ProgramData\ssh\ssh_host_*_key*"

    # Retrying the restart of the sshd service up to 3 times for stability on cloud environments
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            Restart-Service sshd -Force
            break
        }
        catch {
            if ($attempt -eq 3) {
                throw
            }
            Start-Sleep -Seconds 5
        }
    }

    New-Item -ItemType File -Path "C:\ProgramData\ssh\.regenerated"
}