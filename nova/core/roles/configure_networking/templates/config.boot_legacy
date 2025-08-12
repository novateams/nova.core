#!/bin/vbash

# Waiting until ssh.service is running since one of the last services to start
# That way we can be sure that VyOS has booted and is ready to accept commands
while true; do
    if systemctl is-active --quiet ssh.service; then
        break
    else
        sleep 1
    fi
done

# Do not remove following line - VyOS-specific
source /opt/vyatta/etc/functions/script-template

# Find duplicate MAC addresses
# find /sys/class/net -mindepth 1 -maxdepth 1 ! -name lo -printf "%P: " -execdir cat {}/address \;

{% for interface in interfaces %}

    MAC_ADDRESS="{{ configure_networking_mac_addresses[loop.index - 1] }}"
    INTERFACE_NAME=$( ip addr | grep -B1 "$MAC_ADDRESS" | cut -f2 -d":" | grep eth | xargs | grep . | ip addr | grep -B1 "$MAC_ADDRESS" | cut -f2 -d":" | grep eth | xargs)
    set interface ethernet $INTERFACE_NAME description '{{ interface.network_id }}'

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

set service ssh disable-host-validation

# Apply changes and save configuration
commit
save
exit

rm -f /home/vyos/firstconfig.sh