# keycloak

This is a role for installing and configuring Keycloak Docker based on a target machine. It has a limit set of features that can be configured via Ansible variables but more can be added as needed.

## Requirements

- Pre installed certificates under the `/srv/certs` directory for using TLS.
- Pre installed web server for reverse proxying, `nova.core.caddy` can be used for this purpose.

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/keycloak/defaults/main.yml) file for a list and description of the variables used in this role.

Refer to the to the [templated config file](https://github.com/novateams/nova.core/blob/main/nova/core/roles/keycloak/templates/config.j2) for more details on what variables can be used.

To create your own custom configuration template:

1. Use the one provided in the role as a starting point
2. Export the running Keycloak realm configuration from the admin console
3. Modify the template to include the desired configuration based on the exported configuration

## Dependencies

- `nova.core` Ansible collection

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
              protocol: openid-connect # Optional, defaults to openid-connect but can also be saml
              admin_uri: https://providentia.example.com
              base_uri: https://providentia.example.com
              redirect_uris:
                - https://providentia.example.com/*
              root_uri: https://providentia.example.com
              weborigin_uris:
                - https://providentia.example.com/*
              create_client_scope: yes
```
