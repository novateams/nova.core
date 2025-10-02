#!/bin/vbash

exec > >(tee -a /tmp/network.log) 2>&1

# Waiting until vyos-router service prints "migrate system configure", "migrate configure", or "failed!"
# This ensures VyOS has completed its boot process or encountered a failure
while true; do
    if journalctl -b -u vyos-router | grep -q "migrate system configure\|migrate configure\|failed!"; then
        break
    else
        echo "Waiting for vyos-router service to be ready..."
        sleep 1
    fi
done

# Do not remove following line - VyOS-specific
source /opt/vyatta/etc/functions/script-template

{% for interface in interfaces %}
    MAC_ADDRESS="{{ configure_networking_mac_addresses[loop.index - 1] }}"
    INTERFACE_NAME="eth{{ loop.index -1 }}"
    set interface ethernet $INTERFACE_NAME description '{{ interface_names[loop.index0] }}'
    set interface ethernet $INTERFACE_NAME hw-id $MAC_ADDRESS
    set interface ethernet $INTERFACE_NAME mac $MAC_ADDRESS
    {% if interface.addresses | map(attribute='mode') | intersect(['ipv4_dhcp']) %}
        set interfaces ethernet $INTERFACE_NAME address dhcp
    {% endif %}
    {% if interface.addresses | map(attribute='mode') | intersect(['ipv6_dhcp', 'ipv6_slaac']) %}
        set interfaces ethernet $INTERFACE_NAME ipv6 address autoconf
        set interfaces ethernet $INTERFACE_NAME ipv6 dhcpv6-options ia-na
        set interfaces ethernet $INTERFACE_NAME ipv6 dhcpv6-options name-server update
    {% endif %}
    {% if interface.addresses != [] %}
        {% for ip_address in interface.addresses %}
            {% if ip_address.mode == 'ipv4_static' %}
            set interface ethernet $INTERFACE_NAME address {{ ip_address.address }}
            {% endif %}
            {% if ip_address.mode == 'ipv6_static' %}
            set interface ethernet $INTERFACE_NAME address {{ ip_address.address }}
            {% endif %}
            {% if (ip_address.mode == 'ipv4_static') and (no_gateway is not defined) and (ip_address.gateway != none) %}
            set protocols static route 0.0.0.0/0 next-hop {{ ip_address.gateway }}
            {% endif %}
            {% if (ip_address.mode == 'ipv6_static') and (no_gateway is not defined) and (ip_address.gateway != none) %}
            set protocols static route6 ::/0 next-hop {{ ip_address.gateway }}
            {% endif %}
        {% endfor %}
    {% endif %}
{% endfor %}
{% if dns_server_combined != [] %}
    {% for dns_server in dns_server_combined %}
    set system name-server {{ dns_server }}
    {% endfor %}
{% endif %}

# Apply changes and save configuration
commit
save
exit
