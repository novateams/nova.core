# gitlab_runner

- Docker exec runners, installed on linux (docker needs to be installed beforehand).
- PowerShell runners, installed on windows.

## Registration now uses authentication tokens

Introduced in GitLab 15.10, runner registration flow is now moving towards authentication tokens only, previously used registration tokens will be deprecated in Gitlab 18.x.

This means you need acquire an access token from gitlab, before installing and registering new gitlab-runners.

Define your auth token in a runner specific `auth_token` variable.

```yml
gitlab_runner_docker_runners:
  - name: docker_01
    auth_token: glrt-TOKEN
    privileged: false
    executor_image: ubuntu:22.04
```

## Usage

The minimal set of variables to install and register your runner.

- `gitlab_inventory_hostname` or `gitlab_runner_gitlab_url` to define which gitlab will the runner register itself. Can be set globally, or separate in the named runner definition, as `gitlab_url`

- `gitlab_runner_version` is defined in defaults, can override separately with `gitlab_runner_docker_version_tag` or `gitlab_runner_windows_runner_version`

An example of a Docker-in-Docker runner for builing container images.

```yml
gitlab_runner_docker_runners:
  - name: dind_01
    auth_token: glrt-TOKEN
    privileged: false
    services_privileged: true
    extra_hosts:
      - "{{ gitlab_runner_gitlab_fqdn }}:{{ hostvars[gitlab_inventory_hostname].primary_ipv4 }}"
      - "gitlab-registry.{{ domain }}:{{ hostvars[gitlab_inventory_hostname].primary_ipv4 }}"
    allowed_privileged_services:
      - docker.io/library/docker:*-dind
      - docker.io/library/docker:dind
      - docker:*-dind
      - docker:dind
    executor_image: docker:git
    executor_volumes:
      - /certs/client ## needed for dind
      - /var/lib/docker ## for docker image cache on the dind service container
      - /cache
      - /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
```

##

Tags, locked, paused, run_untagged etc runner options are no longer set through gitlab-runner registration, and are now configured only in Gitlab.
