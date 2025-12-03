# docker

This role installs Docker and Docker Compose on the target machine. By default it also configures IPv6 support for Docker and a default network with IPv6 support.

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/docker/defaults/main.yml) file for a list of variables and their default values.

## Dependencies

none

## Examples

```yaml
- name: Including docker role
  ansible.builtin.include_role:
    name: nova.core.docker
```

```yaml
- name: Including docker with multiple custom networks...
  ansible.builtin.include_role:
    name: nova.core.docker
  vars:
    docker_networks:
      - name: local-network
        enable_ipv6: true
        ipv4_subnet: 172.18.0.0/16
        ipv6_subnet: fd42::/64
      - name: local-network2
        enable_ipv6: true
        ipv4_subnet: 172.19.0.0/16
        ipv6_subnet: fd43::/64
```
