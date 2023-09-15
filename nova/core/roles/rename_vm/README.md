# rename_vm

Role for renaming existing VMs, useful for bulk rename.

## Requirements

None

## Role Variables

`old_vm_name` - The current name of the VM to be renamed.
`new_vm_name` - The new name of the VM to be renamed.

## Dependencies

None

## Example

```shell
# Rename single VM from Catapult command line
# Looks up the current VM name and renames it to the new name
ctp-rename-vm <inventory_hostname> -e new_vm_name=<new_vm_name>
```

```yaml
- name: Name of the task
  ansible.builtin.include_role:
    name: nova.core.rename_vm
  vars:
    new_vm_name: <new_vm_name> # Can use variable from group vars to template the new name format for bulk rename
```
