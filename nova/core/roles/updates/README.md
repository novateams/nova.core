# updates

This role is used to update the operating system packages. Currently supported operating systems are: Ubuntu/Debian, Windows & Arch Linux.

Debian family operating systems can be configured to run unattended updates, with additional option to allow unattended reboots if required.

## Requirements

None

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/updates/defaults/main.yml) file for a list of variables and their default values.

## Dependencies

None

## Example

```shell
# Use the existing Catapult CLI alias to only run this role for a specific host.
ctp host update <inventpry_hostname>
```

```yml
# Use the role in a playbook.
- name: Update the operating system
  ansible.builtin.include_role:
    name: nova.core.updates
```
