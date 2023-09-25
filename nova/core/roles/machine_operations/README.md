# Role Name

This role is used to create Virtual Machines in different environments. Currently supported environments are:

- AWS
- Linode
- VMware vSphere
- VMWare Workstation

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/machine_operations/defaults/main.yml) file for a list of variables and their default values.

## Dependencies

Depending on the environment you want to create the VM in, you will need to install the following Ansible collections:

- amazon.aws
- community.aws
- vmware.vmware_rest
- community.vmware

## Example
