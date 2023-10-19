# configure_networking

This is a role to configure networking for a VM after cloning. Currently it is only supporting network configuration for VMs deployed on VMware vSphere, but the scripts are more or less universal and can be modified to add support to different hypervisors. [Here](https://github.com/novateams/nova.core/tree/main/nova/core/roles/configure_networking_with_checks/tasks/vsphere) is a list of all supported network methods.

## Requirements

None

## Role Variables

The variable structure is based on [Providentia](https://github.com/ClarifiedSecurity/Providentia) API output. When using file based inventory then make sure to follow the same structure. Check the example blow for more details.

The variable `customization_method` can take: `bsd`, `macos`, `netplan`, `networkd`, `nmcli`, `routeros`, `vyos`, `windows_cli`

When selecting the network configuration method via the variable `customization_method`, if you are selecting `networkd` option, an extra variable is needed because this option can be used with different OS: `customization_method_distribution`. Possible options: `Debian`, `Archlinux`, `Scientific`

The variable `extra_routes` can be set to add extra routes per interfaces. It takes a list of 3 vars dict:
  - `interface_id`: For the id of the interface
  - `to`: Destination of the route
  - `via`: Gateway
This option is supported only on `netplan` renderer.

## Dependencies

None

## Example

When not using Providentia define the the network configuration in host/group/etc vars in the following format:

```yaml
# Example on how to configure single network interface with static IPv4 and IPv6 addresses and an extra IPv6 address for management traffic
# You can remove the addresses you don't need
# Any undefined value leave to null to avoid errors
interfaces:
  - network_id: my-network-name # Some type of identifiable name. It'll be used for an example in netplan and nmcli interface name
    cloud_id: my-cloud-name # This is a vSphere portgroup name
    domain: my.domain.com
    fqdn: my-host.my.domain.com # FQDN of the VM where the network will be configured
    egress: true # Whether the network is used for egress traffic (connecting to the internet)
    connection: true # Whether the network is used for management traffic (connecting over ssh)
    addresses:
      - pool_id: default-ipv4 # IP pool name
        mode: ipv4_static # IP address mode leave as it is
        connection: false # Whether this IP address is used for management traffic
        address: 192.168.0.0/24 # IP address and subnet mask
        dns_enabled: true # Whether this IP will be registered in DNS (Requires some type of DNS integration)
        gateway: 192.168.0.1 # Gateway IP address

      - pool_id: default-ipv6 # IP pool name
        mode: ipv6_static # IP address mode leave as it is
        connection: false # Whether this IP address is used for management traffic
        address: 2001:0db8:85a3:0000:0000:8a2e:0370:7334/64 # IP address and prefix
        dns_enabled: true # Whether this IP will be registered in DNS (Requires some type of DNS integration)
        gateway: 2001:0db8:85a3:0000:0000:8a2e:0370:7331 # Gateway IP address

      - pool_id: mgmt-ipv6 # IP pool name make sure it contains mgmt
        mode: ipv6_static # IP address mode leave as it is
        connection: true # Whether this IP address is used for management traffic
        address: fd00:1234:5678:abcd::1234/64 # IP address and prefix
        dns_enabled: false # Whether this IP will be registered in DNS (Requires some type of DNS integration)
        gateway: null # Gateway IP address
```
