# customization_post_vm_role

This role is used run extra post-customization tasks on a system once the `customization` role has been finished. It's useful for running additional tasks for a specific group of systems that need to be customized in a specific way. It can be used to include extra roles and tasks and use `when:` statements to run them only on specific systems.

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/customization_post_vm_role/defaults/main.yml) file for a list and description of the variables used in this role.

## Dependencies

none

## Example Playbook

Define a `post_vm_role` role in under your project's `customization_post_vm_role_path` directory defined in this role defaults and the post_vm_role will be picked up by the `start.yml` playbook automatically.
