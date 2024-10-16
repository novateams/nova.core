# firewall

This role is used to install nftables or iptables and template the corresponding configuration for it.

## Requirements

Based on the selected mode needs iptables or nftables configuration files to be present in the `templates` directory of the role that includes the firewall role. For the configuration path variables Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/firewall/defaults/main.yml)

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/firewall/defaults/main.yml) for the full list of variables, their default values and descriptions.

## Dependencies

none

## Example

```yaml
- name: Including firewall role installing nftables and templating config...
  ansible.builtin.include_role:
    name: nova.core.firewall

- name: Including firewall role installing iptables and templating config......
  ansible.builtin.include_role:
    name: nova.core.firewall
  vars:
    mode: iptables
```
