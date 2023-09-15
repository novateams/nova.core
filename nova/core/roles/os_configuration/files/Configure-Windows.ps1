$ErrorActionPreference = 'Stop'

# Time
$TimeZone = "UTC"
Set-Service W32Time -StartupType Automatic
Start-Service W32Time
Set-TimeZone -Id $TimeZone

# Power
powercfg -change -monitor-timeout-ac 0
powercfg -change -standby-timeout-ac 0
powercfg -change -disk-timeout-ac 0
powercfg -change -hibernate-timeout-ac 0
powercfg -change -monitor-timeout-dc 0
powercfg -change -standby-timeout-dc 0
powercfg -change -disk-timeout-dc 0
powercfg -change -hibernate-timeout-dc 0

# https://docs.ansible.com/ansible/latest/os_guide/windows_performance.html#optimize-powershell-performance-to-reduce-ansible-task-overhead
function Optimize-PowershellAssemblies {
	# NGEN powershell assembly, improves startup time of powershell by 10x
	$old_path = $env:path
	try {
	  $env:path = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
	  [AppDomain]::CurrentDomain.GetAssemblies() | % {
		if (! $_.location) {continue}
		$Name = Split-Path $_.location -leaf
		if ($Name.startswith("Microsoft.PowerShell.")) {
		  Write-Progress -Activity "Native Image Installation" -Status "$name"
		  ngen install $_.location | % {"`t$_"}
		}
	  }
	} finally {
	  $env:path = $old_path
	}
  }

Optimize-PowershellAssemblies