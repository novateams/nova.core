# vcenter_vmtools_policy

This role is used to manage the VMware Tools policy on a vSphere Virtual Machine. It can be used to upgrade VMware Tools on a VM or set the policy to check and upgrade VMware Tools on the next reboot.

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/vcenter_vmtools_policy/defaults/main.yml) file for a list and description of the variables used in this role.

## Dependencies

none

## Example

```yml
- name: Upgrading VMware Tools on the VM and setting the upgrade policy to manual...
  ansible.builtin.include_role:
    name: nova.core.vcenter_vmtools_policy

- name: Setting the upgrade policy to check and upgrade VMware Tools on the next reboot...
  ansible.builtin.include_role:
    name: nova.core.vcenter_vmtools_policy
  vars:
    vmtools_upgrade_policy: UPGRADE_AT_POWER_CYCLE
```
