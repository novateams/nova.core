# connect

This role saves the connection information for the inventory_hostname and that info can be used to connect th the machine over supported protocols:

- SSH

## Requirements

none

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/connect/defaults/main.yml) for the full list of variables.

## Dependencies

none

## Example

Manually after including the role:

```bash
ssh $(cat /tmp/ansible_connect)
```

Or with Catapult:

```bash
ctp host connect <TAB>
```
