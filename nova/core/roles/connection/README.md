# connection

This role is used to set connection parameters for the VM after cloning. It parses the correct parameters based on if the VM was just cloned or if it is already been customized. This role can also be used to connect to an already exiting virtual or physical machine. All of the connections are made over SSH.

## Requirements

Credentials for the VM to connect to. This can be either a username and password or a username and SSH key. The VM must also be configured to allow SSH connections.

## Role Variables

`template_username` - The username to connect the freshly cloned machine to run post-configuration there. Usually root or Administrator.
`template_password` - The password to connect the freshly cloned machine to run post-configuration there. Usually root or Administrator.
`connection_address` - The IP address of the machine to connect to.

`ansible_deployer_username` - The username to connect to the machine with once the post-configuration is complete. Usually something that gets created in the `nova.core.accounts` role.
`ansible_deployer_password` - The password to connect to the machine with once the post-configuration is complete. Usually something that gets created in the `nova.core.accounts` role.

## Dependencies

none

## Example

Since this role already gets included in `start.yml` there is no need to include it in your playbook. However, if you want to run it separately, you can do so with:

```yaml
- name: Including connection role
  include_role:
    name: nova.core.connection
```
