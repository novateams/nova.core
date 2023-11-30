from ansible.errors import AnsibleFilterError
from ansible.module_utils.common.text.converters import to_text

DOCUMENTATION = """
    name: getIP
    author: bl0way
    short_description: Get an IP.
    description:
        - Extract the first IP on the selected interface and type from hostvars['vm_name'].
    version_added: 1.1.5
    options:
        hostname_var:
            description: typically hostvars['vm_name'].
            required: True
            type: dict
        network_id:
            description: network_id sent by Providentia, should be also the name of the interface.
            required: True
            type: string
        mode:
            description: sent by Providentia, it must be on of those: ipv4_static, ipv6_static, ipv4_vip or ipv6_vip.
            default: 'ipv4_static'
            required: False
            type: string
        mask:
            description: True will return the IP with the mask, False will not return the mask.
            default: True
            required: False
            type: bool

"""

EXAMPLES = """
    myip: "{{ hostvars['my_vm'] | getIP('my_if', 'ipv4_static', False) }}" # 10.0.0.25
    myip_mask: "{{ hostvars['my_vm'] | getIP('my_if', 'ipv4_static') }}" # 10.0.0.25/24
"""

RETURN = """
  _value:
    description: The IP.
    type: string
"""

class FilterModule(object):

    def filters(self):
        return {
            'getIP': self.getIP
        }

    def getIP(self, hostname_var, network_id, mode='ipv4_static', mask=True):
        # Check mode
        if mode not in [
            'ipv4_static',
            'ipv6_static',
            'ipv4_vip',
            'ipv6_vip'
        ]:
            raise AnsibleFilterError('Mode not supported. Supported modes are: \'ipv4_static\', \'ipv6_static\', \'ipv4_vip\' or \'ipv6_vip\'')
        # Simple search
        for interface_info in hostname_var["interfaces"]:
            if interface_info["network_id"] == network_id:
                for addresses_info in interface_info["addresses"]:
                    if addresses_info["mode"] == mode:
                        # With or without mask
                        if mask:
                            return to_text(addresses_info["address"])
                        return to_text(addresses_info["address"].split('/')[0])
    
        # No result
        raise AnsibleFilterError('IP not found.')
    
