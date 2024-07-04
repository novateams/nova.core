Set-Location {{ gitlab_runner_windows_config_folder }} # Set location is required for the runner to use the config file in $RunnerPath
if ($null -eq (Get-Service | Where-Object Name -like gitlab-runner)) {
    .\gitlab-runner.exe install
}
