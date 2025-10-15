DOCUMENTATION="""
    name: addresses
    short_description: Lookup a specific IP address from Providentia format interfaces list.
    description: |
        This is filter plugin for getting specific addresses from interfaces list. Interfaces list is a variable that is based on Providentia's API
        The interfaces list can also be built manually when Providentia is not used. Example can be found here: https://github.com/novateams/nova.core/tree/main/nova/core/roles/configure_networking#example
        For most cases the filter will print out a list with one item so "| first" can be used to get the value.
        For multiple egress NICs or addresses the list will have multiple items, so the result can be looped through or mapped.
    options:
        connection_address:
            description:
                - Gets the address used for connection to the host.
            required: true
            type: str
        connection_mode:
            description:
                - Gets the method used for setting or getting connection IP address.
            required: true
            type: str
        connection_nic_ipv4:
            description:
                - Gets all connection NIC IPv4 addresses.
            required: true
            type: str
        connection_nic_ipv4_gw:
            description:
                - Gets all connection NIC IPv4 gateways. (There's usually only one)
            required: true
            type: str
        connection_nic_ipv6:
            description:
                - Gets all connection NIC IPv6 addresses.
            required: true
            type: str
        connection_nic_ipv6_gw:
            description:
                - Gets all connection NIC IPv6 gateways. (There's usually only one)
            required: true
            type: str
        egress_nic_ipv4:
            description:
                - Gets all IPv4 addresses for all egress NICs.
            required: true
            type: str
        egress_nic_ipv4_gw:
            description:
                - Gets all IPv4 gateways for all egress NICs.
            required: true
            type: str
        egress_nic_ipv6:
            description:
                - Gets all IPv6 addresses for all egress NICs.
            required: true
            type: str
        egress_nic_ipv6_gw:
            description:
                - Gets all IPv6 gateways for all egress NICs.
            required: true
            type: str
        mgmt_ipv4:
            description:
                - Get's the IPv4 management address if the IP pool with mgmt- prefix is assigned to the NIC.
            required: true
            type: str
        mgmt_ipv6:
            description:
                - Get's the IPv6 management address if the IP pool with mgmt- prefix is assigned to the NIC.
            required: true
            type: str
        connection_nic_vip_ipv4:
            description:
                - Gets all connection NIC VIP IPv4 addresses.
            required: true
            type: str
        connection_nic_vip_ipv6:
            description:
                - Gets all connection NIC VIP IPv6 addresses.
            required: true
            type: str
        egress_nic_vip_ipv4:
            description:
                - Gets all IPv4 VIP addresses for all egress NICs.
            required: true
            type: str
        egress_nic_vip_ipv6:
            description:
                - Gets all IPv6 VIP addresses for all egress NICs.
            required: true
            type: str
    version_added: 0.1.0

"""

EXAMPLES="""
  - name: Get the first connection NIC IPv4 address
    debug:
      msg: "{{ interfaces | nova.core.addresses('connection_nic_ipv4') | first }}"

  - name: Get the first connection NIC IPv4 gateway
    debug:
      msg: "{{ interfaces | nova.core.addresses('connection_nic_ipv4_gw') | first }}"
"""

import re

class FilterModule(object):
    def filters(self):
        return {
            'addresses': self.addresses
        }

    def addresses(self, interfaces, parameter):
        filter_functions = {
            'connection_address': self.get_connection_address(interfaces),
            'connection_mode': self.get_connection_mode(interfaces),

            'connection_nic_ipv4': self.get_addresses_by_mode(interfaces, 'connection', 'ipv4_static'),
            'connection_nic_ipv4_gw': self.get_gateways_by_mode(interfaces, 'connection', 'ipv4_static'),

            'connection_nic_ipv6': self.get_addresses_by_mode(interfaces, 'connection', 'ipv6_static'),
            'connection_nic_ipv6_gw': self.get_gateways_by_mode(interfaces, 'connection', 'ipv6_static'),

            'egress_nic_ipv4': self.get_addresses_by_mode(interfaces, 'egress', 'ipv4_static'),
            'egress_nic_ipv4_gw': self.get_gateways_by_mode(interfaces, 'egress', 'ipv4_static'),

            'egress_nic_ipv6': self.get_addresses_by_mode(interfaces, 'egress', 'ipv6_static'),
            'egress_nic_ipv6_gw': self.get_gateways_by_mode(interfaces, 'egress', 'ipv6_static'),

            'mgmt_ipv4': self.get_mgmt_addresses(interfaces, 'connection', 'ipv4_static'),
            'mgmt_ipv6': self.get_mgmt_addresses(interfaces, 'connection', 'ipv6_static'),

            'connection_nic_vip_ipv4': self.get_addresses_by_mode(interfaces, 'connection', 'ipv4_vip'),
            'connection_nic_vip_ipv6': self.get_addresses_by_mode(interfaces, 'connection', 'ipv6_vip'),

            'egress_nic_vip_ipv4': self.get_addresses_by_mode(interfaces, 'egress', 'ipv4_vip'),
            'egress_nic_vip_ipv6': self.get_addresses_by_mode(interfaces, 'egress', 'ipv6_vip'),
        }

        result = filter_functions.get(parameter, [])
        return result if result else ['null']  # Return 'null' if result is empty

    def get_connection_mode(self, interfaces):
        for interface in interfaces:
            if interface.get('connection'):
                for address in interface.get('addresses', []):
                    if address.get('connection'):
                        return [address.get('mode')]
        return None

    def get_addresses_by_mode(self, interfaces, interface_type, mode):
        addresses = []
        for interface in interfaces:
            if interface.get(interface_type):
                for address in interface.get('addresses', []):
                    if self.validate_address(address, mode):
                        address_val = address['address']
                        addresses.append(address_val if address_val else 'null')  # Append 'null' if address is an empty string
        return addresses

    def get_gateways_by_mode(self, interfaces, interface_type, mode):
        gateways = []
        for interface in interfaces:
            if interface.get(interface_type):
                for address in interface.get('addresses', []):
                    if self.validate_address(address, mode):
                        gateway = address['gateway']
                        gateways.append(gateway if gateway is not None else 'null')  # Append 'null' if gateway is None
        return gateways

    def get_mgmt_addresses(self, interfaces, interface_type, mode):
        addresses = []
        for interface in interfaces:
            if interface.get(interface_type):
                for address in interface.get('addresses', []):
                    if self.validate_mgmt_address(address, mode) and re.match(r'^mgmt-.*', address['pool_id']):
                        address_val = address['address']
                        addresses.append(address_val if address_val else 'null')  # Append 'null' if address is an empty string
        return addresses

    def get_connection_address(self, interfaces):
        addresses = []
        for interface in interfaces:
            for address in interface.get('addresses', []):
                if address.get('connection'):
                    address_val = address.get('address')
                    addresses.append(address_val if address_val else 'null')
        return addresses

    def validate_address(self, address, mode):
        return address.get('mode') == mode and address.get('address') and address.get('pool_id').startswith('default-')

    def validate_mgmt_address(self, address, mode):
        return address.get('mode') == mode and address.get('address') and address.get('pool_id').startswith('mgmt-')
