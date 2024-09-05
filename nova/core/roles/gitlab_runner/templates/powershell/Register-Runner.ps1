$ErrorActionPreference = "Stop"

$RunnerName = "{{ runner.name }}"
$GitLabURI = "{{ gitlab_runner_gitlab_url }}"
$RunnerPath = "{{ gitlab_runner_windows_config_folder }}"
$RunnerToken = "{{ runner.auth_token }}"
$Template = "{{ gitlab_runner_windows_config_folder }}\{{ runner.name }}\gitlab-runner-config.template.toml"

Set-Location $RunnerPath # Set location is required for the runner to use the config file in $RunnerPath
.\gitlab-runner.exe register --non-interactive `
--name $RunnerName `
--url $GitLabURI `
--token $RunnerToken `
--template-config $Template
