# Providentia

This is a role for installing [Providentia](https://github.com/ClarifiedSecurity/Providentia) in Docker on a Ubuntu/Debian host.

## Requirements

- Tested on Ubuntu 22.04 but should work on any Debian based system.

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/providentia/defaults/main.yml) for the full list of variables, their default values and descriptions.

Required variables:

- `providentia_app_fqdn` - which DNS name will be used for the application

If included, the keycloak will be using `keycloak.{{ providentia_app_fqdn }}` as its FQDN.

## Dependencies

- Depends on Docker and Docker Compose being installed on the host. By default, [nova.core.docker](https://github.com/novateams/nova.core/tree/main/nova/core/roles/docker) role is included, this can be disabled by setting `providentia_install_docker` to false.
- Certificates for reverse proxy, if used with TLS

## Notes

The builtin keycloak is configured with HTTP by default, as Providentia does not trust self-signed certificates. This can and should be altered in real deployments.

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

      providentia_builtin_keycloak: false
      providentia_oidc_issuer: https://keycloak.example.com/realms/Providentia
      providentia_oidc_client_id: ProvidentiaLive
      providentia_oidc_client_secret: 12345
```
