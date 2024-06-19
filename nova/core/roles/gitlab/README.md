# Gitlab

This role installs and configures Gitlab with Docker Compose. https://docs.gitlab.com/
Optionally it can also configure:

- LDAP authentication
- SMTP service
- Gitlab Pages
- Gitlab Registry

## Requirements

- Tested on Ubuntu 22.04 but should work on any Debian based system.
- Requires an external reverse proxy (nginx, traefik, haproxy, caddy etc.) in front of Gitlab to handle GUI access and TLS termination.

## Role Variables

Refer to `defaults/main.yml` for the minimal needed variables to install a clean gitlab instance, their default values and descriptions.

### Required Variables for Installation

- `fqdn`
- `gitlab_docker_network`
- `gitlab_initial_root_personal_passwd`
- `gitlab_root_personal_token`

## Example

Including the gitlab role will install gitlab and apply some general instance wide settings.

```yaml
# Installs Gitlab
- name: Installing Gitlab...
  ansible.builtin.include_role:
    name: nova.core.gitlab
```

## To further configure gitlab, groups, users, projects etc

Include extra tasks by referring to them in your vm role, for example, include `mnt-groups.yml` tasks to create groups in your gitlab.

```yaml
- name: Include tasks from gitlab role..
  ansible.builtin.include_role:
    name: nova.core.gitlab
    tasks_from: mnt-groups.yml
```

## Useful links

https://www.unavco.org/gitlab/help/administration/troubleshooting/gitlab_rails_cheat_sheet.md
https://docs.gitlab.com/ee/api/
