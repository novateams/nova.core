# nexus

This is a role for installing and configuring [Nexus Repository Manager 3](https://help.sonatype.com/repomanager3) on a in Docker on a Ubuntu/Debian host. This role can be used for following:

- Install Nexus with Docker Compose
- Run initial configuration of Nexus (optional)
- Install LDAP configuration for Nexus (optional)

## Requirements

- Tested on Ubuntu 22.04 but should work on any Debian based system.
- Requires an external reverse proxy (nginx, traefik, haproxy, caddy etc.) in front of Nexus to handle GUI access and TLS termination.

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/nexus/defaults/main.yml) for the full list of variables, their default values and descriptions.

### Required Variables for Installation

- `docker_network`

### Required Variables for Configuration

- `fqdn`
- `nexus_admin_password`

### Required Variables for LDAP Configuration

- `nexus_ldap_name`
- `nexus_ldap_host`
- `nexus_ldap_search_base`
- `nexus_bind_user_dn`
- `nexus_bind_user_password`
- `nexus_groups_dn_under_searchbase`
- `nexus_nexus_ldap_administrators_group`

Alternatively the whole `nexus_ldap_configuration` block can be defined as a single variable to configure LDAP. See [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/nexus/defaults/main.yml) for the full list of variables.

## Dependencies

- Depends on Docker and Docker Compose being installed on the host. Docker can be installed using the [nova.core.docker](https://github.com/novateams/nova.core/tree/main/nova/core/roles/docker) role.

## Example

```yaml
# Installs Nexus without configuring it. Initial configuration can be done manually from the web GUI.
- name: Installing Nexus...
  ansible.builtin.include_role:
    name: nova.core.nexus

# Installs Nexus and runs initial configuration on it.
- name: Installing & configuring Nexus...
  ansible.builtin.include_role:
    name: nova.core.nexus
  vars:
    nexus_configure: true
    nexus_admin_password: # lookup to a predefined password that will be applied to the admin user on first run

# Installs Nexus and runs initial configuration on it and configures LDAP.
- name: Installing & configuring Nexus...
  ansible.builtin.include_role:
    name: nova.core.nexus
  vars:
    nexus_configure: true
    nexus_admin_password: # lookup to a predefined password that will be applied to the admin user on first run
    nexus_configure_ldap: true
    nexus_ldap_name: example.com
    nexus_ldap_host: dc1.example.com
    nexus_ldap_search_base: OU=ORG,DC=example,DC=com
    nexus_bind_user_dn: CN=svc_nexus,OU=Service Accounts,OU=ORG,DC=example,DC=com
    nexus_groups_dn_under_searchbase: OU=Nexus,OU=Resources
    nexus_bind_dn_password: # lookup to a predefined password for the svc_nexus user
    nexus_ldap_administrators_group: Nexus Admins
```
