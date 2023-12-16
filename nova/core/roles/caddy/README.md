# caddy

This is a role for installing and configuering [Caddy](https://caddyserver.com/docs/) web server.

## Requirements

none

## Role Variables

## Dependencies

- Depends on Docker and Docker Compose being installed on the host. Docker can be installed using the [nova.core.docker](https://github.com/novateams/nova.core/tree/main/nova/core/roles/caddy) role.

## Example

```yaml
# Installing Caddy server that listens on all addresses and reverse proxies to an internal server
- name: Installing Caddy...
  ansible.builtin.include_role:
    name: nova.core.caddy
  vars:
    caddy_servers:
    - caddy_server_name: web.example.com # Name of the server
        caddy_server_listen_addresses:
        - ":"
        caddy_server_reverse_proxy_to_address: http://internal.example.com
```

```yaml
# Installing Caddy server that listens only on port 80 with TLS disabled and reverse proxies to an internal server
- name: Installing Caddy...
  ansible.builtin.include_role:
    name: nova.core.caddy
  vars:
    caddy_servers:
      - caddy_server_name: web.example.com # Name of the server
        caddy_server_listen_addresses:
          - ":80"
        caddy_server_reverse_proxy_to_address: http://internal.example.com
        caddy_use_tls: false
```

```yaml
# Installing Caddy server that listens only on all ports with TLS enabled and reverse proxies to an internal server
# Only responds to requests for www.example.com and www2.example.com
- name: Installing Caddy...
  ansible.builtin.include_role:
    name: nova.core.caddy
  vars:
    caddy_servers:
      - caddy_server_name: www.example.com # Name of the server
        caddy_server_listen_addresses:
          - www.example.com
          - www2.example.com
        caddy_server_reverse_proxy_to_address: http://internal.example.com
```
