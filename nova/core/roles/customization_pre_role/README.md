# customization_pre_role

This role gets loaded in `start.yml` before any connection is made to the Ansible inventory host. It can be used include roles that interact with different services or APIs directly from the Catapult container. It'll first check if a role name matching `pre_role` variable exists in `roles` and includes it. If no role exits it'll try to include the role based on the FQCN defined in `pre_role` variable. After the include role is complete the play stops.

## Requirements

`pre_role` variable must be defined

## Role Variables

`pre_role` - role name in `roles` folder or role FQCN to be included.

## Dependencies

None

## Example

Example on how the `pre_role` can be used to build snapshot [aliases](https://github.com/ClarifiedSecurity/catapult/blob/main/container/home/builder/.default_aliases#L59-L69) for Catapult

## License

AGPL-3.0-or-later
