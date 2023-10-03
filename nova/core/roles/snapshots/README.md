# Role Name

This is a role for creating and managing snapshots of virtual machines. Currently supported environments are: `vSphere` & `VMware Workstation`.

## Requirements

none

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/snapshots/defaults/main.yml) for the full list of variables, their default values and descriptions.

One of the following variables must be set:

- `snapshot_mode == 'snap'` # Adds a new snapshot to the VM
- `snapshot_mode == 'resnap'` # Removes all existing snapshots from the VM and adds a new one
- `snapshot_mode == 'live-snap'` # Adds a new snapshot to the VM while it is running

## Dependencies

none

## Example

```yml
- name: Removing all existing snapshots from a VM and creating a new one with a name LinkedCloneSource and not starting VM after snapshot...
  ansible.builtin.include_role:
    name: nova.core.snapshots
  vars:
    snapshot_mode: resnap
    snapshot_name: LinkedCloneSource
    start_vm_after_snapshot: false
```

```yml
- name: Adding a new snapshot to a VM while it is running...
  ansible.builtin.include_role:
    name: nova.core.snapshots
  vars:
    snapshot_mode: live-snap
```

```yml
- name: Shutting down a VM, adding a new snapshot to it and starting it again...
  ansible.builtin.include_role:
    name: nova.core.snapshots
  vars:
    snapshot_mode: snap
```
