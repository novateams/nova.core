# linux_xrdp_server

This roles installs and configures XRDP on a Debian based Linux machine.

## Requirements

none

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/linux_xrdp_server/defaults/main.yml) for the full list of variables, their default values and descriptions.

## Dependencies

none

## Example

```yaml
- name: Inlcude role linux_xrdp_server
  ansible.builtin.include_role:
    name: nova.core.linux_xrdp_server
```
