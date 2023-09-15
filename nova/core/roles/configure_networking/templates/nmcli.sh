#!/bin/bash

set -e # exit when any command fails

if [ -z "$(nmcli c)" ]; then
    echo "No connections present"
else
    nmcli -t -f UUID con | xargs nmcli conn delete
fi

# Looping over Providentia interfaces
{% for interface in interfaces %}

    LOCAL_INTERFACE_NAME=$(ip -o link show | awk -F': ' '{if ($2 != "lo") print $2}' | awk 'NR=={{ loop.index }}')
    NMCLI_CONNECTION_NAME=$LOCAL_INTERFACE_NAME-{{ interface.network_id }} # This is to make sure that nmcli connection name is unique

    nmcli connection add type ethernet ifname $LOCAL_INTERFACE_NAME con-name $NMCLI_CONNECTION_NAME

    # Looping over IP addresses
    {% for ip_address in interface.addresses %}

        {% if (ip_address.mode == 'ipv4_static') and (ip_address.gateway is defined) and (ip_address.gateway != none) %}

            # Adding IPv4 addresses with GW for interface
            nmcli con modify $NMCLI_CONNECTION_NAME ipv4.method manual +ipv4.addresses {{ ip_address.address }} ipv4.gateway {{ ip_address.gateway }}

        {% elif (ip_address.mode == 'ipv4_static') and (ip_address.gateway is not defined or ip_address.gateway == none) %}

            # Adding IPv4 addresses without GW for interface
            nmcli con modify $NMCLI_CONNECTION_NAME ipv4.method manual +ipv4.addresses {{ ip_address.address }}

        {% elif (ip_address.mode == 'ipv6_static') and (ip_address.gateway is defined) and (ip_address.gateway != none) %}

            # Adding IPv6 addresses with GW for interface
            nmcli con modify $NMCLI_CONNECTION_NAME ipv6.method manual +ipv6.addresses {{ ip_address.address }} ipv6.gateway {{ ip_address.gateway }}

        {% elif (ip_address.mode == 'ipv6_static') and (ip_address.gateway is not defined or ip_address.gateway == none) %}

            # Adding IPv6 addresses without GW for interface
            nmcli con modify $NMCLI_CONNECTION_NAME ipv6.method manual +ipv6.addresses {{ ip_address.address }}

        {% endif %}

    {% endfor %}

    {% if extra_ipv4[ interface.network_id ] is defined %}

        # Adding extra ipv4 addresses for connection interface
        nmcli con modify $NMCLI_CONNECTION_NAME ipv4.method manual +ipv4.addresses "{{ extra_ipv4[ interface.network_id ] | join(', ') }}"

    {% endif %}

    {% if extra_ipv6[ interface.network_id ] is defined %}

        # Adding extra ipv6 addresses for connection interface
        nmcli con modify $NMCLI_CONNECTION_NAME ipv6.method manual +ipv6.addresses "{{ extra_ipv6[ interface.network_id ] | join(', ') }}"

    {% endif %}

    {% if (mgmt_ip != {}) and (interface.connection) %}

        # Adding MGMT address for connection interface
        nmcli con modify $NMCLI_CONNECTION_NAME ipv6.method manual +ipv6.addresses {{ mgmt_ip | ansible.utils.ipaddr('address') }}

    {% endif %}

    # Adding ipv4 DNS servers
    {% if (dns_servers is defined) and (dns_servers != []) %}

        nmcli con modify $NMCLI_CONNECTION_NAME +ipv4.dns "{{ dns_servers | join(", ") }}"

    {% endif %}

    # Adding ipv6 DNS servers
    {% if (dns_servers6 is defined) and (dns_servers6 != []) %}

        nmcli con modify $NMCLI_CONNECTION_NAME +ipv6.dns "{{ dns_servers6 | join(", ") }}"

    {% endif %}

{% endfor %}

nmcli networking off && nmcli networking on