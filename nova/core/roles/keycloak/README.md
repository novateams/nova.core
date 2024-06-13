# keycloak

This is a role for installing and configuring Keycloak Docker based on a target machine.

## Requirements

- Pre installed certificates under the `/srv/certs` directory for using TLS.
- Pre installed web server for reverse proxying, `nova.core.caddy` can be used for this purpose.

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/keycloak/defaults/main.yml) file for a list and description of the variables used in this role.

## Dependencies

- `nova.core.docker`

## Example

```yaml
# Example on how to install Keycloak with Providentia client and LDAPs (AD) group mapper
dependencies:
  - role: nova.core.keycloak
    vars:
      keycloak_use_custom_jks: false # Set to true if using internal CA that is not trusted by Keycloak by default
      keycloak_realms:
        - realm_name: Apps
          sso_session_idle_timeout: 172800 ## 2 days
          sso_session_max_lifespan: 604800 ## 7 days
          configure_ldap: yes
          ldap_server: ldaps://dc1.example.com
          users_search_dn: OU=Users,DC=example,DC=com
          bind_user_dn: CN=keycloak.service.account,OU=Service Accounts,DC=example,DC=com
          bind_user_password: Password123
          custom_user_search_filter:
            - "(&(objectClass=person)(mail=*))"

          ldap_role_mappers:
            - client_name: Providentia
              ldap_groups_dn: OU=Groups,DC=example,DC=com

          clients:
            - client_name: Providentia
              admin_uri: https://providentia.example.com
              base_uri: https://providentia.example.com
              redirect_uris:
                - https://providentia.example.com/*
              root_uri: https://providentia.example.com
              weborigin_uris:
                - https://providentia.example.com/*
              create_client_scope: yes
```
