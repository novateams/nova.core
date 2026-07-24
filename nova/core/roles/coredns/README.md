# coredns

This role installs and configures CoreDNS on Debian-based systems and allows generating zonefiles and configuring forwarders for CoreDNS

## Requirements

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/coredns/defaults/main.yml) file for a list and description of the variables used in this role.

## Dependencies

- Depends on Docker and Docker Compose being installed on the host. Docker can be installed using the [nova.core.docker](https://github.com/novateams/nova.core/tree/main/nova/core/roles/docker) role.

## Example

```yml
# Installing CoreDNS without any custom zonefiles or forwarders
# By default it'll use DoT (DNS over TLS) to forward all requests to Cloudflare or Google if Cloudflare is not reachable.
- name: Including CoreDNS role...
  ansible.builtin.include_role:
    name: nova.core.coredns
```

```yml
# Installing CoreDNS and generating custom zonefiles based on the provided coredns_records variable.
# 2 zonefiles will be generated, one for example.com and one for example.org with the provided records.
- name: Including CoreDNS role...
  ansible.builtin.include_role:
    name: nova.core.coredns
  vars:
    coredns_records:
      - domain: example.com
        records:
          - type: A
            name: www
            value: 10.0.0.1
          - type: AAAA
            name: www
            value: 2001:db8::1
          - type: CNAME
            name: mail
            value: mail.example.com
      - domain: example.org
        records:
          - type: A
            name: www
            value: 10.0.0.2
```

```yml
# Installing CoreDNS and generating custom zonefiles based on the provided coredns_records variable.
# 2 zonefiles will be generated, one for example.com and one for example.org with the provided records.
# Additionally setting custom nameservers for example.com zone when nameservers is not defined, CoreDNS will itself act as the nameserver for the zone.
- name: Including CoreDNS role...
  ansible.builtin.include_role:
    name: nova.core.coredns
  vars:
    coredns_records:
      - domain: example.com
        # OPTIONAL
        nameservers:
          - name: ns1
            address: 10.10.10.1
          - name: ns1
            address: 2001:db8::1
          - name: ns2
            address: 10.10.10.2
        records:
          - type: A
            name: www
            value: 10.0.0.1
          - type: AAAA
            name: www
            value: 2001:db8::1
          - type: CNAME
            name: mail
            value: mail.example.com
      - domain: example.org
        records:
          - type: A
            name: www
            value: 10.0.0.2
```

```yml
# Installing CoreDNS without any zonefiles but with custom forwarders defined in the coredns_forwarders variable.
# CoreDNS will now forward requests for example.com and example.org to the specified DNS servers.
- name: Including CoreDNS role...
  ansible.builtin.include_role:
    name: nova.core.coredns
  vars:
    coredns_forwarders:
      - domains:
          - example.com
          - example.org
        addresses:
          - 10.10.10.1
          - 2001:db8::1
```
