# powerstate

This role can be used to manage the powerstate of a Virtual Machine. It can be used to power on-off, reset, susepend or reboot a VM.

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/powerstate/defaults/main.yml) file for a list and description of the variables used in this role.

## Dependencies

none

## Example Playbook

```yml
- name: Shutting down the VM...
  ansible.builtin.include_role:
    name: nova.core.powerstate
  vars:
    shutdown: true # This will try a graceful shutdown

- name: Powering on the VM...
  ansible.builtin.include_role:
    name: nova.core.powerstate
  vars:
    poweron: true

- name: Rebooting the VM...
  ansible.builtin.include_role:
    name: nova.core.powerstate
  vars:
    restart: true

- name: Suspending the VM...
  ansible.builtin.include_role:
    name: nova.core.powerstate
  vars:
    suspend: true

- name: Resetting the VM...
  ansible.builtin.include_role:
    name: nova.core.powerstate
  vars:
    reset: true

- name: Powering off the VM...
  ansible.builtin.include_role:
    name: nova.core.powerstate
  vars:
    poweroff: true # This will force a power off
```
