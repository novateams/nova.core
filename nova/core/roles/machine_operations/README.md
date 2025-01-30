# machine_operations

This role is used to create Virtual Machines in different environments. Currently supported environments are:

- AWS
- Linode
- VMware vSphere
- VMWare Workstation
- Proxmox

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/machine_operations/defaults/main.yml) file for a list of variables and their default values.

A required variable is `infra_env` this will tell the playbook which environment to create the VM in. Available options are:

- aws
- linode
- vmware
- vmware_workstation
- proxmox
- external (Skip the VM creation and move on to connection task)

## Dependencies

none

## Example

This role already get's included by the `start.yml` playbook and does not need to be included separately.
