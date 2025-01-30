#!/bin/sh

# Logging script output
exec > /tmp/network.log 2>&1

set -e # exit when any command fails

# Timeout duration in seconds
TIMEOUT=180 # 5 minutes
START_TIME=$(date +%s)

# Wait until the pve-cluster service is running
until systemctl is-active --quiet pve-cluster; do
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
    if [ $ELAPSED_TIME -ge $TIMEOUT ]; then
        echo "Timed out waiting for pve-cluster service to start"
        exit 1
    fi
    echo "Waiting for pve-cluster service to start..."
    sleep 3
done

MGMT_INTERFACE_NAME={{ configure_networking_proxmox_mgmt_interface_name }}
NODE_NAME={{ configure_networking_proxmox_node_name | default("$(hostname)") }}

{% if mgmt_ipv4 != false %}

pvesh set /nodes/$NODE_NAME/network/$MGMT_INTERFACE_NAME --type bridge \
--address {{ mgmt_ipv4 | ansible.utils.ipaddr('address') }} \
--netmask {{ mgmt_ipv4 | ansible.utils.ipaddr('netmask') }} \
{% if connection_nic_ipv6 != false %}
--address6 {{ connection_nic_ipv6 }} \
--netmask6 {{ connection_nic_ipv6_with_prefix | ansible.utils.ipaddr('prefix') }} \
{% endif %}
{% if connection_nic_ipv6_gw != false %}
--gateway6 {{ connection_nic_ipv6_gw }}
{% endif %}

{% elif mgmt_ipv6 != false %}

pvesh set /nodes/$NODE_NAME/network/$MGMT_INTERFACE_NAME --type bridge \
--address6 {{ mgmt_ipv6 }} \
--netmask6 {{ mgmt_ipv6_with_prefix | ansible.utils.ipaddr('prefix') }} \
{% if connection_nic_ipv4 != false %}
--address {{ connection_nic_ipv4 }} \
--netmask {{ connection_nic_ipv4_with_prefix | ansible.utils.ipaddr('netmask') }} \
{% endif %}
{% if connection_nic_ipv4_gw != false %}
--gateway {{ connection_nic_ipv4_gw }}
{% endif %}

{% else %}

pvesh set /nodes/$NODE_NAME/network/$MGMT_INTERFACE_NAME --type bridge \
{% if connection_nic_ipv4 != false %}
--address {{ connection_nic_ipv4 }} \
--netmask {{ connection_nic_ipv4_with_prefix | ansible.utils.ipaddr('netmask') }} \
{% endif %}
{% if connection_nic_ipv4_gw != false %}
--gateway {{ connection_nic_ipv4_gw }} \
{% endif %}
{% if connection_nic_ipv6 != false %}
--address6 {{ connection_nic_ipv6 }} \
--netmask6 {{ connection_nic_ipv6_with_prefix | ansible.utils.ipaddr('prefix') }} \
{% endif %}
{% if connection_nic_ipv6_gw != false %}
--gateway6 {{ connection_nic_ipv6_gw }}
{% endif %}

{% endif %}

# Reload network configuration
pvesh set /nodes/$NODE_NAME/network
