#!/bin/bash

set -e # exit when any command fails

# Looping over Providentia interfaces
{% for interface in interfaces %}
{% if interface.addresses != [] %}

    LOCAL_INTERFACE_NAME=$(networksetup -listallhardwareports | grep "Hardware Port:" | cut -d ":" -f2 | tr -d ' ' | awk 'NR=={{ loop.index }}')

    # Looping over IP addresses
    {% for ip_address in interface.addresses %}
        {% if not ip_address.pool_id | regex_search("mgmt-.*") %}

            {% if (ip_address.mode == 'ipv4_static') and (ip_address.gateway != none) %}

                # Adding IPv4 addresses with GW for interface
                networksetup -setmanual $LOCAL_INTERFACE_NAME {{ ip_address.address | ansible.utils.ipaddr('address') }} {{ ip_address.address | ansible.utils.ipaddr('netmask')}} {{ ip_address.gateway }}

            {% elif (ip_address.mode == 'ipv4_static') and (ip_address.gateway == none) %}

                # Adding IPv4 addresses without GW for interface
                networksetup -setmanual $LOCAL_INTERFACE_NAME {{ ip_address.address | ansible.utils.ipaddr('address') }} {{ ip_address.address | ansible.utils.ipaddr('netmask')}}

            {% elif (ip_address.mode == 'ipv6_static') and (ip_address.gateway != none) %}

                # Adding IPv6 addresses with GW for interface
                networksetup -setv6manual $LOCAL_INTERFACE_NAME {{ ip_address.address | ansible.utils.ipaddr('address') }} {{ ip_address.address | ansible.utils.ipaddr('prefix') }} {{ ip_address.gateway }}

            {% elif (ip_address.mode == 'ipv6_static') and (ip_address.gateway == none) %}

                # Adding IPv6 addresses without GW for interface
                networksetup -setv6manual $LOCAL_INTERFACE_NAME {{ ip_address.address | ansible.utils.ipaddr('address') }} {{ ip_address.address | ansible.utils.ipaddr('prefix') }}

            {% endif %}

        # Configuring MGMT interface
        {% elif ip_address.pool_id | regex_search("mgmt-.*") %}

            # Removing MGMT interface if it exists
            if [[ $(networksetup -listallnetworkservices | grep "MGMT") ]]; then

                networksetup -removenetworkservice MGMT

            fi

            {% if ip_address.mode == 'ipv6_static' %}

                # Creating MGMT interface, disabling IPv4 address for it and adding IPv6 address
                networksetup -createnetworkservice MGMT $LOCAL_INTERFACE_NAME
                networksetup -setv4off MGMT
                networksetup -setv6manual MGMT {{ ip_address.address | ansible.utils.ipaddr('address') }} {{ ip_address.address | ansible.utils.ipaddr('prefix') }}

            {% elif ip_address.mode == 'ipv4_static' %}

                # Creating MGMT interface, disabling IPv6 address for it and adding IPv6 address
                networksetup -createnetworkservice MGMT $LOCAL_INTERFACE_NAME
                networksetup -setv6off MGMT
                networksetup -setmanual MGMT {{ ip_address.address | ansible.utils.ipaddr('address') }} {{ ip_address.address | ansible.utils.ipaddr('netmask')}}

            {% endif %}

        {% endif %}
    {% endfor %}

    # Setting DNS servers
    networksetup -setdnsservers $LOCAL_INTERFACE_NAME {{ dns_server_combined | join(' ') }}

    # Disabling and enabling interface to apply changes
    networksetup -setnetworkserviceenabled $LOCAL_INTERFACE_NAME off
    sleep 5 # Otherwise it'll happen to fast and IPv6 won't work. It's still faster then doing a reboot.
    networksetup -setnetworkserviceenabled $LOCAL_INTERFACE_NAME on

{% endif %}
{% endfor %}