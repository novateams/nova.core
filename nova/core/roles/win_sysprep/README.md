# win_sysprep

This is a role for running sysprep on a Windows host running on vSphere. This is automatically included in the `nova.core.template_os_configuration` role, but can be run independently if desired.

## Requirements

none

## Role Variables

`post_sysprep_administrator_password` - The password for the Administrator account after sysprep is run. Defaults to current `ansible_user`.

## Dependencies

none

## Example

```yaml
- name: Running sysprep...
  include_role: nova.core.win_sysprep
  vars:
    post_sysprep_administrator_password: "MyNewPassword"
```
