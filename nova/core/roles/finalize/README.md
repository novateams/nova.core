# finalize

This role is usually used as a last role in a playbook. It is used to clean up some of the artifacts that are created during the deployment process. It can also be used to updates the operating system and include some extra last-stop roles.

## Requirements

none

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/finalize/defaults/main.yml) for the full list of variables, their default values and descriptions.

## Dependencies

none

## Example

```yaml
- name: Including finalize role to update Operating System...
  ansible.builtin.include_role:
    name: nova.core.finalize
  vars:
    update_system: true
```
