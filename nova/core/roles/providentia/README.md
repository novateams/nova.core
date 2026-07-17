# providentia

This is a role for installing [Providentia](https://github.com/ClarifiedSecurity/Providentia) in Docker on a Ubuntu/Debian host.

## Requirements

- Tested on Ubuntu 22.04 but should work on any Debian based system.
- Minimum supported Providentia version: **v25.4.0**

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/providentia/defaults/main.yml) for the full list of variables, their default values and descriptions.

Required variables:

- `providentia_app_fqdn` - which DNS name will be used for the application

If included, the SSO will be using `sso-{{ providentia_app_fqdn }}` as its default FQDN.

## Dependencies

- Depends on Docker and Docker Compose being installed on the host. By default, [nova.core.docker](https://github.com/novateams/nova.core/tree/main/nova/core/roles/docker) role is included, this can be disabled by setting `providentia_install_docker` to false.
- (Optional) Certificates for reverse proxy, if used with TLS, uses self-signed certificates if not provided

## Notes

The builtin SSO is _not_ secure by default and is meant as a placeholder for a real SSO setup

- it is configured to work with HTTP (as Providentia does not trust self-signed certificates)
- the accounts created are described on [main repository page](https://github.com/ClarifiedSecurity/Providentia#demo-credentials)
- it allows redirection to any origin

This can and should be altered in real deployments!

By default, the prebuilt image will be pulled from github - setting `providentia_deploy_branch` variable will clone the repository and build the image on host instead.

## Example

```yaml
# Installs Providentia with all components at FQDN `providentia.example.com`
- name: Installing Providentia...
  ansible.builtin.include_role:
    name: nova.core.providentia
  vars:
    providentia_app_fqdn: providentia.example.com

# Installs Providentia with all components at FQDN `providentia.example.com` with pregenerated TLS
- name: Installing Providentia...
  ansible.builtin.include_role:
    name: nova.core.providentia
  vars:
    providentia_app_fqdn: providentia.example.com
    providentia_builtin_reverse_proxy_tls_mode: pregenerated
    providentia_builtin_reverse_proxy_tls_pregenerated_cert: "/srv/certs/providentia.example.com_fullchain.crt"
    providentia_builtin_reverse_proxy_tls_pregenerated_key: "/srv/certs/providentia.example.com_key.crt"

# Installs Providentia at FQDN `providentia.example.com` with pregenerated TLS and external OpenID Connect provider
- name: Installing Providentia...
  ansible.builtin.include_role:
    name: nova.core.providentia
  vars:
    providentia_app_fqdn: providentia.example.com
    providentia_builtin_reverse_proxy_tls_mode: pregenerated
    providentia_builtin_reverse_proxy_tls_pregenerated_cert: "/srv/certs/providentia.example.com_fullchain.crt"
    providentia_builtin_reverse_proxy_tls_pregenerated_key: "/srv/certs/providentia.example.com_key.crt"

    providentia_builtin_sso: false
    providentia_oidc_issuer: https://keycloak.example.com/realms/Providentia
    providentia_oidc_client_id: ProvidentiaLive
    providentia_oidc_client_secret: 12345
```
