# linux_xrdp_keyboard

This role is used to add extra keyboard layouts to the xrdp server. It's useful for adding keyboard layouts that are not included in the default xrdp installation.

## Requirements

XRDP must already be installed on the system. It can be done with the `linux_xrdp_server` role.

## Role Variables

none

## Dependencies

none

## Example

```yml
- name: Including linux_xrdp_keyboard role...
  ansible.builtin.include_role:
    name: nova.core.linux_xrdp_keyboard
```
