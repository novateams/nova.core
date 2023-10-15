# template_os_configuration

This is a role to pre-configure a VM template. It is reccomeneded that you have your VM templates in separate project or separately in your project's inventory so you use this role to configure them for use with the rest of the roles in this collection.

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/template_os_configuration/defaults/main.yml) file for a list and description of the variables used in this role.

Currently some of the when conditions expect you to have specificly named group vars defined for certain settings to applied.

Examples:

`os_bsd` - for BSD based distros
`os_linux` - for Linux based distros
`os_windows` - for Windows OS

## Dependencies

none

## Example

```yaml
- name: Including OS configuration role with updates...
  ansible.builtin.include_role:
    name: nova.core.template_os_configuration
  vars:
    update_system: true
```
