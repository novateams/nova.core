# deploy_vars

This role is used to set required deploy variables. Is is used as the very first role in the deploy process. By using this role, we can ensure that all required variables are set before any other roles are executed. This role also caches the required variables in a file so that they can be used by other roles.

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/deploy_vars/defaults/main.yml) file for a list and description of the variables used in this role.

Pre-built variables that come from the Providentia inventory plugin if it's used. These can be useful when working with multiple projects with the same name. To avoid using incorrect information for projects, the deployer username and password can be prefixed with either `project` or `project` and `environment` to make them unique.

The username and password of the deployer for a specific project in a specific environment. When both `project` and `environment` are defined in the Providentia inventory configuration.

`env_project_deployer_username`
`env_project_deployer_password`

For the following example Providentia inventory configuration the variables in Ansible Vault can be `test_testing_deployer_username` and `test_testing_deployer_password`.

```yaml
---
plugin: nova.core.providentia_v3
providentia_host: https://providentia.example.com
project: testing
environment: test
sso_token_url: https://keycloak.example.com/realms/Apps/protocol/openid-connect/token
```

The password of the deployer for a specific project in a specific environment. When only `project` is defined in the Providentia inventory configuration.

`project_deployer_username`
`project_deployer_password`

For the following example Providentia inventory configuration the variables in Ansible Vault can be `testing_deployer_username` and `testing_deployer_password`.

```yaml
---
plugin: nova.core.providentia_v3
providentia_host: https://providentia.example.com
project: testing
sso_token_url: https://keycloak.example.com/realms/Apps/protocol/openid-connect/token
```

## Dependencies

none

## Example

```yaml
- name: Including deploy_vars role...
  ansible.builtin.include_role:
    name: nova.core.deploy_vars
```
