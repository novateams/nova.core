#!/bin/sh

# Logging script output
exec > /tmp/network.log 2>&1

set -e # exit when any command fails

# Looping over Providentia interfaces to find the connection interface
{% for interface in interfaces %}
{% if interface.connection %}

    MGMT_INTERFACE_NAME={{ configure_networking_esxi_mgmt_interface_name }}

    # Looping over connection IP addresses
    {% for ip_address in interface.addresses %}

        {% if (ip_address.mode == 'ipv4_static') and (ip_address.gateway != none) %}

            # Adding IPv4 addresses with GW for interface
            esxcli network ip interface ipv4 set -i $MGMT_INTERFACE_NAME -I {{ ip_address.address | ansible.utils.ipaddr('address') }} -N {{ ip_address.address | ansible.utils.ipaddr('netmask')}} -g {{ ip_address.gateway }} -t static

            # Adding default route
            esxcli network ip route ipv4 add -g {{ ip_address.gateway }} -n 0.0.0.0/0

        {% elif (ip_address.mode == 'ipv4_static') and (ip_address.gateway is not defined or ip_address.gateway == none) %}

            # Adding IPv4 addresses without GW for interface
            esxcli network ip interface ipv4 set -i $MGMT_INTERFACE_NAME -I {{ ip_address.address | ansible.utils.ipaddr('address') }} -N {{ ip_address.address | ansible.utils.ipaddr('netmask')}} -t static

        {% elif (ip_address.mode == 'ipv6_static') and (ip_address.gateway != none) %}

            # Adding IPv6 addresses with GW for interface

            # Removing existing IPv6 address if it exists
            if esxcli network ip interface ipv6 address list -i $MGMT_INTERFACE_NAME | grep -q {{ ip_address.address | ansible.utils.ipaddr('address') }}; then
                esxcli network ip interface ipv6 address remove -i $MGMT_INTERFACE_NAME -I {{ ip_address.address }}
            fi

            esxcli network ip interface ipv6 address add -i $MGMT_INTERFACE_NAME -I {{ ip_address.address }}
            esxcli network ip route ipv6 add -g {{ ip_address.gateway }} -n ::/0

        {% elif (ip_address.mode == 'ipv6_static') and (ip_address.gateway is not defined or ip_address.gateway == none) %}

            # Adding IPv6 addresses without GW for interface

            # Removing existing IPv6 address if it exists
            if esxcli network ip interface ipv6 address list -i $MGMT_INTERFACE_NAME | grep -q {{ ip_address.address | ansible.utils.ipaddr('address') }}; then
                esxcli network ip interface ipv6 address remove -i $MGMT_INTERFACE_NAME -I {{ ip_address.address }}
            fi

            esxcli network ip interface ipv6 address add -i $MGMT_INTERFACE_NAME -I {{ ip_address.address }}

        {% endif %}

    {% endfor %}

{% endif %}
{% endfor %}
