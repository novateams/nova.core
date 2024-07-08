# vault

This is a role for installing and configuring [Hashicorp Vault](https://www.hashicorp.com/products/vault). This role can be used to:

- Run initial setup of Vault
- Configure Vault to integrate with LDAP
- Enable and configure the PKI secrets engine

During initial setup of Vault, the root token and unseal key(s) are saved to `/srv/vault/creds` folder. Make sure to move these to a safe location after initial setup and use Ansible lookup plugins to retrieve them when needed.

## Requirements

- Requires an external reverse proxy (nginx, traefik, haproxy, caddy etc.) to handle GUI access and TLS termination.

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/vault/defaults/main.yml) for the full list of variables, their default values and descriptions.

## Dependencies

- Depends on Docker and Docker Compose being installed on the host. Docker can be installed using the [nova.core.docker](https://github.com/novateams/nova.core/tree/main/nova/core/roles/docker) role.

## Example

```yaml
# Installing Vault with default values and configuring everything manually
- name: Installing Vault...
  ansible.builtin.include_role:
    name: nova.core.vault
```

```yaml
# Installing Vault and running initial configuration
- name: Installing & configuring Vault...
  ansible.builtin.include_role:
    name: nova.core.vault
    vars:
      vault_configure: true
```

```yaml
# Installing Vault and running initial configuration and configuring LDAP
- name: Installing & configuring Vault with LDAP...
  ansible.builtin.include_role:
    name: nova.core.vault
    vars:
      vault_configure: true
      vault_configure_ldap: true
      vault_configuration_uri: https://vault.example.com
      vault_binddn: CN=svc_nexus,OU=Service Accounts,OU=ORG,DC=example,DC=com
      vault_bindpass: # lookup to a predefined password for the svc_nexus user
      vault_groupdn: OU=Vault,OU=Groups,OU=ORG,DC=example,DC=com
      vault_upndomain: example.com
      vault_ldaps_url: ldaps://dc1.example.com # Can be LDAP or LDAPS
      vault_userdn: OU=Users,OU=ORG,DC=example,DC=com
      vault_ldaps_certificate_source: /usr/local/share/ca-certificates/LDAPRootCA.crt # Path or URL to the LDAP server's root CA certificate
```

```yaml
# Installing Vault and running initial configuration and configuring LDAP and creating a policy for developers
- name: Installing & configuring Vault with LDAP...
  ansible.builtin.include_role:
    name: nova.core.vault
    vars:
      vault_configure: true
      vault_configure_ldap: true
      vault_configuration_uri: https://vault.example.com
      vault_binddn: CN=svc_nexus,OU=Service Accounts,OU=ORG,DC=example,DC=com
      vault_bindpass: # lookup to a predefined password for the svc_nexus user
      vault_groupdn: OU=Vault,OU=Groups,OU=ORG,DC=example,DC=com
      vault_upndomain: example.com
      vault_ldaps_url: ldaps://dc1.example.com # Can be LDAP or LDAPS
      vault_userdn: OU=Users,OU=ORG,DC=example,DC=com
      vault_ldaps_certificate_source: /usr/local/share/ca-certificates/LDAPRootCA.crt # Path or URL to the LDAP server's root CA certificate
      vault_policies:
        - policy_name: developers
          policy_content: |-
            path "developers/data/*" { capabilities = ["create", "read", "update", "patch", "delete", "list"] }
            path "developers/metadata/*" { capabilities = ["create", "read", "update", "patch", "delete", "list"] }
            path "developers/metadata" { capabilities = ["list"] }
          vault_group_name: developers
          ldap_group_name: vault-developers # This is the LDAP group name that will be mapped to the Vault group for this policy
```

```yaml
# Installing Vault and running initial configuration and configuring PKI with default values
- name: Installing & configuring Vault with PKI...
  ansible.builtin.include_role:
    name: nova.core.vault
    vars:
      vault_configure: true
      vault_create_root_ca: true # Create a self-signed root CA
      vault_create_intermediate_ca: true # Create an intermediate CA (signed by the root CA)
```
