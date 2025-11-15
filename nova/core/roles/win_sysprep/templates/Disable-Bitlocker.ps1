$ErrorActionPreference = 'Stop'

if (Get-Module -ListAvailable -Name BitLocker) {

    if ("FullyDecrypted" -ne (Get-BitLockerVolume | Where-Object MountPoint -EQ "C:" | Select-Object -ExpandProperty VolumeStatus)) {

        Write-Host "Disabling BitLocker on C: drive..."
        Disable-BitLocker -MountPoint "C:"
        Write-Host "Waiting for BitLocker decryption to complete..."

        do {
            $Percentage = Get-BitLockerVolume | Where-Object MountPoint -EQ "C:" | Select-Object -ExpandProperty EncryptionPercentage
            Write-Host "Decryption in progress... $Percentage% left."
            Start-Sleep -Seconds 10
        } until (

            "FullyDecrypted" -eq (Get-BitLockerVolume | Where-Object MountPoint -EQ "C:" | Select-Object -ExpandProperty VolumeStatus)
        )

        Write-Host "BitLocker decryption completed."

    } else {

        Write-Host "BitLocker not enabled"

    }

} else {

    Write-Host "BitLocker not enabled"

}
