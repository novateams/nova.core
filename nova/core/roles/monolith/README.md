# monolith

This is a role for combining multiple roles into a single role for installing and configuring a monolithic application on a target machine.
This role combines the following roles:

- `nova.core.caddy`
- `nova.core.vault`
- `nova.core.keycloak`
- `nova.core.providentia`
- `nova.core.nexus`

It's meant for easy deployment of all required services for running a Cyber Exercise. The role generates and writes it's application default credentials into Vault. The login token for the Vault can be found at `/srv/vault/creds/root_token`.

## Requirements

- Pre existing/installed and configured Active Directory (AD) server for LDAPs.
- Pre installed Debian based OS (Ubuntu 22.04 preferred) with SSH & sudo access where the application will be installed if not pre-existing infrastructure is present.
- TLS certificate for all services under the `/srv/certs/{{ fqdn }}_fullchain.crt` must be pre-installed. Alternatively, the `nova.core.caddy` role will generate self-signed certificates.
- The DNS names defined in `monolith_*` variables must be resolvable from the host where this role is executed from.

## Role Variables

These variables need to be defined in the host_var or passed from command line in order to connect and configure the previously cloned host where the monolith will be installed.

```yaml
infra_env: external # This says that the host where monolith is manually set up and not cloned by nova.core.machine_operations rol
save_secrets_to_vault: false # By default  not saving secrets to vault because we're setting it up in this run

# This is list of internal CA certificates will trusted by the monolith services for an example for LDAPS.
# Remove this list if globally trusted CA certificates are used also for LDAPs.
trusted_certificates_list:
  - name: LDAPS
    src: "{{ playbook_dir }}/files/LDAPS.crt"

connection_address: 10.10.10.10 # This is the IP address of the host where monolith will be installed
ansible_deployer_username: # This is the username that will be used to connect to the host
ansible_deployer_password: # This is the password that will be used to connect to the host
hostname: # This is the hostname that will be set for the host
domain: # This is the domain that will be set for the host
ad_domain_name: "{{ domain }}"
fqdn: "{{ hostname }}.{{ domain }}"
project_fullname: # This is the full name of the project
```

Although there are some variables available to this role, it recommended to only set values for variables defined in the example below. This is a kickstart role and should be used as such. Advanced users can install the individual roles separately for more control.

`-e monolith_single_service=service_name` can be appended to command line to only configure single service after the initial setup.

## Dependencies

none

## Example

```yaml
# Example on how to install and configure all monolith services when using LetsEncrypt (or other globally trusted CA) certificates
dependencies:
  - role: nova.core.trusted_certificates # This will created a JKS file from the trusted certificates.
    vars:
      trusted_certificates_to_jks: true

  - role: nova.core.monolith
    vars:
      monolith_providentia_fqdn: providentia.{{ domain }} # This is the FQDN that will be used for Providentia
      monolith_nexus_fqdn: nexus.{{ domain }} # This is the FQDN that will be used for Nexus
      monolith_keycloak_fqdn: keycloak.{{ domain }} # This is the FQDN that will be used for Keycloak
      monolith_vault_fqdn: vault.{{ domain }} # This is the FQDN that will be used for Vault

      ############
      # Keycloak #
      ############

      keycloak_use_custom_jks: false # Set to true if using internal CA that is not trusted by Keycloak by default
      keycloak_realms:
        - realm_name: Apps
          sso_session_idle_timeout: 172800 ## 2 days
          sso_session_max_lifespan: 604800 ## 7 days
          configure_ldap: yes
          ldap_server: ldaps://dc1.example.com # This is the LDAP server that will be used for Keycloak
          users_search_dn: OU=Users,DC=example,DC=com # This is the search base for users in LDAP
          bind_user_dn: CN=keycloak.service.account,OU=Service Accounts,DC=example,DC=com # This is the bind user for LDAP
          bind_user_password: Password123 # This is the password for the bind user
          custom_user_search_filter:
            - "(&(objectClass=person)(mail=*))" # This is the custom user search filter for LDAP that makes sure only users with email are imported

          ldap_role_mappers:
            - client_name: Providentia # This is the client name that will be used for LDAP role mapping
              ldap_groups_dn: OU=Groups,DC=example,DC=com # This is the search base for groups in LDAP

          clients:
            - client_name: Providentia
              admin_uri: https://{{ monolith_providentia_fqdn }}
              base_uri: https://{{ monolith_providentia_fqdn }}
              redirect_uris:
                - https://{{ monolith_providentia_fqdn }}/*
              root_uri: https://{{ monolith_providentia_fqdn }}
              weborigin_uris:
                - https://{{ monolith_providentia_fqdn }}/*
              create_client_scope: yes

      ###############
      # Providentia #
      ###############

      providentia_app_fqdn: "{{ monolith_providentia_fqdn }}"
      providentia_resource_prefix: providentia- # This is the resource prefix that will be used for Providentia, all LDAP groups must start with this prefix. For logging into Providentia, the user must be a member of a providentia-Admin group.

      #########
      # Vault #
      #########

      vault_proxy_container_name: caddy
      vault_binddn: CN=vault.service.account,OU=Service Accounts,DC=example,DC=com # This is the bind user for LDAP
      vault_bindpass: Password123 # This is the password for the bind user
      vault_groupdn: OU=Groups,DC=example,DC=com # This is the search base for groups in LDAP
      vault_upndomain: "{{ domain }}" # This is the UPN domain for LDAP
      vault_ldaps_url: ldaps://dc1.example.com # This is the LDAP server that will be used for Vault
      vault_userdn: OU=Users,DC=example,DC=com # This is the search base for users in LDAP
      vault_ldap_admin_group_name: vault-admins # This is the LDAP group that will have admin access to Vault

      vault_create_root_ca: true # Create a self-signed root CA
      vault_create_intermediate_ca: true # Create an intermediate CA (signed by the root CA)

      #########
      # Nexus #
      #########

      nexus_proxy_container_name: caddy
      nexus_ldap_name: "{{ domain }}" # This is the name of the LDAP configuration in Nexus
      nexus_ldap_host: dc1.example.com # This is the LDAP server that will be used for Nexus
      nexus_ldap_search_base: DC=example,DC=com # This is the search base for users in LDAP
      nexus_bind_user_dn: CN=nexus.service.account,OU=Service Accounts,DC=example,DC=com # This is the bind user for LDAP
      nexus_groups_dn_under_searchbase: OU=Groups # This is the search base for groups in LDAP under the nexus_ldap_search_base
      nexus_bind_dn_password: Password123 # This is the password for the bind user
      nexus_ldap_administrators_group: nexus-admins # This is the group that will be used for Nexus administrators
```
