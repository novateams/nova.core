# linux_xrdp_server

This roles installs and configures xrdp on a Linux machine.

## Requirements

none

## Role Variables

All required role variables are coming from gather_facts.

## Dependencies

none

## Example

```yaml
- name: Inlcude role linux_xrdp_server
  ansible.builtin.include_role:
    name: nova.core.linux_xrdp_server
```
