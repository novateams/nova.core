$ErrorActionPreference = 'Stop'

# Looping the whole thing 3 times since some packages are dependent on others and will not be removed until the dependent package is removed first.
# This is a known issue with Appx packages and is expected behavior.
for ($iteration = 1; $iteration -le 3; $iteration++) {

Write-Host "Running iteration $iteration/3"

$Provisioned = @{}
foreach ($p in Get-AppxProvisionedPackage -Online) {
    $parts = $p.PackageName -split '_'
    $Provisioned["$($parts[0])_$($parts[-1])"] = [version]$p.Version
}

$Blockers = Get-AppxPackage | Where-Object {
    -not $_.IsFramework -and
    $_.NonRemovable -ne $true -and
    $_.SignatureKind -ne 'System'
} | Where-Object {
    $v = $Provisioned[$_.PackageFamilyName]
    -not $v -or [version]$_.Version -ne $v
}

foreach ($Package in $Blockers) {
    try {
        Write-Host "Removing $($Package.PackageFullName)..."
        Remove-AppxPackage -Package $Package.PackageFullName
    } catch {
        Write-Warning "Failed: $($Package.PackageFullName): $($_.Exception.Message)"
    }
}

}
