# samba

This role is for installing Samba 4 Domain Controller on Debian based systems.

## Requirements

- Requires certificates to be present on the target system if LDAPS is enabled.

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/samba/defaults/main.yml) for the full list of variables, their default values and descriptions.

## Dependencies

none

## Example

```yaml
- name: Including samba role
  ansible.builtin.include_role:
    name: nova.core.samba
```

```yaml
- name: Including samba with custom domain variables
  ansible.builtin.include_role:
    name: nova.core.samba
  vars:
    samba_domain_name: my.domain
    samba_domain_netbios: MYDOMAIN
    samba_domain_admin_username: administrator
    samba_domain_admin_password: SuperSecretPassword
    samba_ldaps_enable: true
    samba_ldaps_cert_file: /etc/ssl/certs/my_domain_cert.pem
    samba_ldaps_key_file: /etc/ssl/private/my_domain_key.pem
    samba_ldaps_ca_file: /etc/ssl/certs/my_domain_ca.pem
```
