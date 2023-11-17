# customization

This is a universal role that can be included in [start.yml](https://github.com/ClarifiedSecurity/catapult/blob/main/defaults/start.yml). It is used to look for existence of a role in the `customization_role_path` and include it if it exists.

## Requirements

none

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/customization/defaults/main.yml) for the full list of variables.

## Dependencies

none

## Example

Since this role already gets included in `start.yml` there is no need to include it in your playbook. However, if you want to run it separately, you can do so with:

```yaml
- name: Including customization role
  include_role:
    name: nova.core.customization
```
