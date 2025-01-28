# cleanup

This role is used to run OS cleanup tasks on a system as one of the final steps in a playbook. It's mostly used for Lab and Exercise environments where you don't want to leave any traces of the Ansible playbook behind for the students or participants to see.

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/cleanup/defaults/main.yml) file for a list and description of the variables used in this role.

The `cleanup` role can be included in start.yml playbook by the `finalize` role. If `finalize_cleanup_system: true` is set in host or group vars, the cleanup role will be executed at the end of the playbook.

## Dependencies

none

## Example

```yml
- name: Including cleanup role...
  ansible.builtin.include_role:
    name: nova.core.cleanup
```
