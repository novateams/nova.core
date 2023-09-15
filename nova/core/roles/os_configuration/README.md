# os_configuration

This is a universal role that is included in [start.yml](https://github.com/ClarifiedSecurity/catapult/blob/main/defaults/start.yml). It is used to run different general operating system configuration tasks. Such as configuring hostname, Windows activation, Linux host ssh keys and machine id regeneration etc.

## Requirements

None

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/os_configuration/defaults/main.yml) for the full list of variables.

## Dependencies

None

## Example

Since this role already gets included in `start.yml` there is no need to include it in your playbook. However, if you want to run it separately, you can do so with:

```yaml
- name: Including os_configuration role
  include_role:
    name: nova.core.os_configuration
```
