# outline

This is a role for installing [Outline Wiki](https://www.getoutline.com/) using local storage and Docker Compose.

## Requirements

`Docker` - Can be installed using the `nova.core.docker` role.
`Web Proxy` - Can be installed using the `nova.core.caddy` role.
`TLS Certificates` - Can be self-signed or obtained from a trusted CA like Let's Encrypt. Can be requested using the `nova.core.caddy` role if Caddy is accessible from the internet.

## Role Variables

Refer to the [defaults/main.yml](https://github.com/ClarifiedSecurity/nova.core/blob/main/nova/core/roles/outline/defaults/main.yml) file for a list of variables and their default values.

## Dependencies

`nova.core` Ansible collection installed

## Example

```yaml
# Fix any errors reported from missing variables by adding them to your project's group_vars/host_vars files.
---
# Include all of the required dependencies in a another roles meta/main.yml file.
dependencies:
  - role: nova.core.docker

  - role: nova.core.outline

  - role: nova.core.caddy
    vars:
      caddy_servers:
        - caddy_server_name: "{{ fqdn }}"
          caddy_server_listen_addresses:
            - "{{ fqdn }}"
          caddy_server_reverse_proxy_to_address: http://outline:3000
```
