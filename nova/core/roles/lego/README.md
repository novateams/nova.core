# lego

This is a role for installing [lego](https://go-acme.github.io/lego/) to automatically update TLS certificates.

## Requirements

This role is the engine for managing TLS certificates using lego you'll need pass lego configuration and env file with this role based on the specific requirements of your environment. Refer to the [lego documentation](https://go-acme.github.io/lego/obtain/) on how to create `.lego.yml` file for your selected provider.

## Role Variables

Refer to the [defaults/main.yml](https://github.com/ClarifiedSecurity/nova.core/blob/main/nova/core/roles/lego/defaults/main.yml) file for a list of variables and their default values.

## Dependencies

none

## Example

```yaml
---
- name: Including lego role...
  ansible.builtin.include_role:
    name: nova.core.lego
  vars:
    lego_config_file: lego_config.yml # REQUIRED lego_config.yml file in the templates folder of the role that includes nova.core.lego role
    lego_env_file: lego_env # REQUIRED lego_env file in the templates folder of the role that includes nova.core.lego role
    lego_post_hook_script: lego_post_request_hook.sh # OPTIONAL post hook script to be executed after lego certificate renewal
```
