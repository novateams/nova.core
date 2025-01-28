# snapshots

This is a role for creating and managing snapshots of virtual machines. Currently supported environments are: `vSphere`, `VMware Workstation` & `Proxmox VE`.

## Requirements

none

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/snapshots/defaults/main.yml) for the full list of variables, their default values and descriptions.

One of the following variables must be set:

- `snapshot_mode == 'snap'`
  - If `live_snap: true` - Adds a new snapshot to the VM with the live memory
  - If `live_snap: false` - Shuts down VM, adds a new snapshot to the VM, starts the VM
- `snapshot_mode == 'clean-snap'`
  - If `live_snap: true` - Removes all existing snapshots from the VM, adds a new one
  - If `live_snap: false` - Shuts down VM, removes all existing snapshots from the VM, starts the VM
- `snapshot_mode == 're-snap'`
  - If `live_snap: true` - Deletes the current snapshot from the VM and creates a new one
  - If `live_snap: false` - Shuts down VM, removes the current snapshot from the VM, starts the VM
- `snapshot_mode == 'revert'`
  - Reverts the VM to the snapshot with the name specified in `snapshot_name`
  - If no `snapshot_name` is specified, the current snapshot will be used
- `snapshot_mode == 'rename'`
  - Renames the snapshot with the name specified in `snapshot_name` variable with a name defined in the `new_snapshot_name` variable
- `snapshot_mode == 'remove'`
  - Removes the snapshot with the name specified in `snapshot_name` variable.
  - If no `snapshot_name` is specified, the current snapshot will be used
  - If `remove_all_snapshots: true` all snapshots will be removed

Modifiers:

- `live_snap` (true|false) - Affects `snap`, `clean-snap`, `re-snap`
- `snapshot_name` (string) - Used to interact with the snapshots
- `new_snapshot_name` (string) - Only used when `rename`
- `start_vm_after_snapshot` (true|false)
- `start_vm_after_revert` (true|false)
- `remove_all_snapshots` (true|false)

## Dependencies

none

## Example

```yml
- name: Removing all existing snapshots from a VM and creating a new one with a name LinkedCloneSource and not starting VM after snapshot...
  ansible.builtin.include_role:
    name: nova.core.snapshots
  vars:
    snapshot_mode: clean-snap
    snapshot_name: LinkedCloneSource
    start_vm_after_snapshot: false
```

```yml
- name: Adding a new snapshot to a VM while it is running...
  ansible.builtin.include_role:
    name: nova.core.snapshots
  vars:
    snapshot_mode: snap
    live_snap: true
```

```yml
- name: Shutting down a VM, adding a new snapshot to it and starting it again...
  ansible.builtin.include_role:
    name: nova.core.snapshots
  vars:
    snapshot_mode: snap
```

```yml
- name: Deleting the current snapshot from a VM...
  ansible.builtin.include_role:
    name: nova.core.snapshots
  vars:
    snapshot_mode: remove
    snapshot_name: LinkedCloneSource
```

```yml
- name: Deleting all snapshots from a VM...
  ansible.builtin.include_role:
    name: nova.core.snapshots
  vars:
    snapshot_mode: remove
    snapshot_name: LinkedCloneSource
    remove_all_snapshots: true
```

```yml
- name: Renaming a snapshot of a VM...
  ansible.builtin.include_role:
    name: nova.core.snapshots
  vars:
    snapshot_mode: rename
    snapshot_name: OldSnapshotName
    new_snapshot_name: NewSnapshotName
```

```yml
- name: Reverting to a snapshot called MySnapshotName of a VM...
  ansible.builtin.include_role:
    name: nova.core.snapshots
  vars:
    snapshot_mode: revert
    snapshot_name: MySnapshotName
```
