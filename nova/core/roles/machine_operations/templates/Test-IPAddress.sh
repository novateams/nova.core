#!/bin/sh

{% if connection_address is ansible.utils.ipv6 %}
if [ -x "$(command -v ping6)" ]; then
    ping6 -c 2 {{ connection_address }}
else
    ping -c 2 -W 2 {{ connection_address }}
fi
{% else %}
ping -c 2 -W 2 {{ connection_address }}
{% endif %}