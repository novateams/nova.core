# expo

This role is used to deploy Exercise Portal (EXPO) to a VM.

## Requirements

Certificates, which are defined in the defaults.

## Role Variables

See [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/expo/defaults/main.yml) for the full list of variables.

## Dependencies

- Depends on Docker and Docker Compose being installed on the host. Docker can be installed using the [nova.core.docker](https://github.com/novateams/nova.core/tree/main/nova/core/roles/docker) role.

## Example

```yaml
- name: Including connection role
  include_role:
    name: nova.core.expo
```
