# win_test_pending_reboot

This role tests if a Windows host has a pending reboot. It downloads and installs the [PendingReboot](https://www.powershellgallery.com/packages/PendingReboot) PowerShell module from the PowerShell Gallery and uses it to check if a reboot is required.

## Requirements

None

## Role Variables

none

## Dependencies

None

## Example

```yml
# Include the role
- name: Including the win_test_pending_reboot module...
  ansible.builtin.include_role:
    name: nova.core.win_test_pending_reboot
```
