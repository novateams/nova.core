# get_ip

This role will look up the IP addresses (IPv4 & IPv6) and FQDN of an Ansible inventory host and print them out.

## Requirements

None

## Role Variables

None

## Dependencies

None

## Example

```yaml
# Include the role
- name: Get IP address of host
  ansible.builtin.include_role:
    name: nova.core.get_ip
```

```yaml
# Include the role in meta
---
- dependencies:
    - role: nova.core.get_ip
```

```shell
# Use the command in Catapult
ctp host ip <inventory_hostname>
```

## License

AGPL-3.0-or-later
