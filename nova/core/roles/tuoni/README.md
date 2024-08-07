# tuoni

This is a role for installing the [Tuoni C2 framework](https://tuoni.io/) on Debian-based host.

## Requirements

none

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/tuoni/defaults/main.yml) for the full list of variables.

## Dependencies

none

## Example

```yaml
- name: Including Tuoni role...
  ansible.builtin.include_role: nova.core.tuoni
```
