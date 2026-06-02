# frr

This role installs and configures FRR on Debian-based systems. It adds the official FRR repository, installs the FRR packages, and can be used to manage the FRR configuration.

## Requirements

Requires and existing `frr.conf` file to be present in the `templates` directory of the role that includes this role, or a custom path to be provided with the `frr_template_file` variable. The configuration file will be rendered with the variables provided to this role, so make sure to use the correct variable names in the template.

Previous understanding of how to configure FRR is needed to use this role, as the role does not provide any default configuration and only manages the installation and configuration file rendering.

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/frr/defaults/main.yml) file for a list and description of the variables used in this role.

## Dependencies

none

## Example

```yml
# Installing frr, enabling ospf for ipv6 and using a custom template file for the configuration
- name: Including frr role...
  ansible.builtin.include_role:
    name: nova.core.frr
  vars:
    frr_template_file: custom_frr.conf
    frr:
      ospf:
        ipv4: false
        ipv6: true
        priority: 254
      bgp: false
      pbr: false
```
