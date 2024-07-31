# Role Name

This role is responsible for managing admin and user accounts for different operating systems. Crrently, this role supports the following operating systems:

- CentOS/RHEL
- Cisco IOS
- FreeBSD
- MacOS
- Opnsense
- Palo Alto Networks PAN-OS
- PfSense
- RouterOS
- Ubuntu/Debian
- VyOS
- Windows (Domain & Local accounts)

## Requirements

For most Unix based distributions `sudo` needs to be pre-installed.

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/accounts/defaults/main.yml) file for a list and description of the variables used in this role.

## Dependencies

none

## Example

```yaml
# Define the admin accounts list in host_vars/group_vars or role variables to create the admin accounts for the OS
admin_accounts:
  - username: root # When password is not defined it'll be randomly generated

  - username: admin
    password: Password123
    ssh_key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIB8J
```

```yaml
# Define the user accounts list in host_vars/group_vars or role variables to create the user accounts for the OS
user_accounts:
  - username: user1 # When password is not defined it'll be randomly generated

  - username: user2
    password: Password123
    ssh_key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIB8J
```

```yaml
# Define the domain_user_accounts accounts list in host_vars/group_vars or role variables to create the domain user accounts for the Domain Controller
domain_user_accounts:
  - username: user1 # When password is not defined it'll be randomly generated

  - username: user2
    password: Password123
```
