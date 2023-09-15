# win_dc_post_reboot_check

Role for waiting for Windows Domain Controller to be ready after reboot. Useful to include in playbooks after DC reboot to avoid errors where Ansible tries to configure DC before it is ready.

## Requirements

None

## Role Variables

None

## Dependencies

None

## Example

```yaml
# Include the role in tasks
- name: Name of the task
  ansible.builtin.include_role:
    name: nova.core.win_dc_post_reboot_check
```

```yaml
# Include the role in meta
---
- dependencies:
    - role: nova.core.win_dc_post_reboot_check
```
