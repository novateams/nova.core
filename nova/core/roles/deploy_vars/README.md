# deploy_vars

This role is used to set required deploy variables. Is is used as the very first role in the deploy process. By using this role, we can ensure that all required variables are set before any other roles are executed. This role also caches the required variables in a file so that they can be used by other roles.

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/deploy_vars/defaults/main.yml) file for a list and description of the variables used in this role.

## Dependencies

none

## Example

```yaml
- name: Including deploy_vars role...
  ansible.builtin.include_role:
    name: nova.core.deploy_vars
```
