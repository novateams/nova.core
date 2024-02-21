# customization_single_role

This is a role to include and run a single Ansible role. The role name can be in the for of path/to/role or the FQCN of the role.

## Requirements

none

## Role Variables

`single_role` variable is required to be set to the name of the role you want to include and run.

## Dependencies

none

## Example

Include and run the `nova.core.updates` from command line by appending the cli variable to your playbook command:

```bash
ansible-playbook -i inventory playbook.yml -e single_role=nova.core.updates
```
