$ErrorActionPreference = 'Stop'

#------------------------------------End of variables, Start of Script----------------------------------------------------------------------------------------------------------

Write-Host "Running sysprep..."
& $env:SystemRoot\System32\Sysprep\Sysprep.exe /generalize /shutdown /oobe
