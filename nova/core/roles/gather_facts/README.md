# gather_facts

This role is used to gather facts about the target being managed. A separate role is used to better filter between different OS types and their gather facts modules. Also so this role can be dynamically included in other roles.

## Requirements

none

## Role Variables

none

## Dependencies

none

## Example

```yml
# Gathering facts for any OS supported by this collection
- name: Including gather_facts role...
  ansible.builtin.include_role:
    name: nova.core.gather_facts
```
