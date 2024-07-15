# role_metadata_post

This is a role for gathering posting role specific metadata to Providentia or custom metadata server at the end of the deploy. The metadata itself can be gathered with the `nova.core.role_metadata_generate` role.

## Requirements

none

## Role Variables

Required variables are:

- `role_metadata_post_keycloak_uri` - The URI of the Keycloak server used for Providentia authentication.
- `role_metadata_post_providentia_uri` - The URI of the Providentia server.
- `role_metadata_post_keycloak_realm_name` - The name of the Keycloak realm used for Providentia authentication.

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/role_metadata_generate/defaults/main.yml) file for a list and description of the variables used in this role.

## Dependencies

none

## Example

```yaml
# all.yml or some other group_vars file
generate_role_metadata: true # Generates role metadata where applicable and posts it to Providentia in nova.core.finalize role
role_metadata_post_providentia_uri: https://providentia.example.com
role_metadata_post_keycloak_uri: https://keycloak.example.com
role_metadata_post_keycloak_realm_name: master
```
