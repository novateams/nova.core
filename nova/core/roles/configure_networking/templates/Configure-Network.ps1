
$ErrorActionPreference = 'Stop'

# Removing existing IPs & Gateways
Get-NetIPAddress | Where-Object InterfaceAlias -NotLike Loopback* | Remove-NetIPAddress -Confirm:$false
Get-NetRoute | Where-Object InterfaceAlias -NotLike Loopback* | Remove-NetRoute -Confirm:$false

# Looping over Providentia interfaces
{% for interface in interfaces %}

$Interface = "Ethernet{{ loop.index -1 }}"

# Looping over IP addresses
{% for ip_address in interface.addresses %}

{% if (ip_address.mode == 'ipv4_static') and (ip_address.gateway is defined) and (ip_address.gateway != none) %}

# Excluding IPv4 gateway if it already exists
if ($null -eq (Get-NetIPConfiguration | Select-Object -ExpandProperty IPv4DefaultGateway)) {

    New-NetIPAddress -AddressFamily IPv4 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interface -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }} -DefaultGateway {{ ip_address.gateway }}

} else {

    New-NetIPAddress -AddressFamily IPv4 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interface -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }}
}

{% elif (ip_address.mode == 'ipv4_static') and (ip_address.gateway is not defined or ip_address.gateway == none) %}
New-NetIPAddress -AddressFamily IPv4 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interface -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }}
{% endif %}

{% if (ip_address.mode == 'ipv6_static') and (ip_address.gateway is defined) and (ip_address.gateway != none) %}

# Excluding IPv6 gateway if it already exists
if ($null -eq (Get-NetIPConfiguration | Select-Object -ExpandProperty IPv6DefaultGateway)) {

    New-NetIPAddress -AddressFamily IPv6 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interface -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }} -DefaultGateway {{ ip_address.gateway }}

} else {

    New-NetIPAddress -AddressFamily IPv6 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interface -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }}
}

{% elif (ip_address.mode == 'ipv6_static') and (ip_address.gateway is not defined or ip_address.gateway == none) %}
New-NetIPAddress -AddressFamily IPv6 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interface -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }} -SkipAsSource $true
{% endif %}

{% endfor %}

{% if (mgmt_ip != {}) and (interface.connection) %}
New-NetIPAddress -AddressFamily IPv6 -IPAddress {{ mgmt_ip | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interface -PrefixLength {{ mgmt_ip | ansible.utils.ipaddr('prefix') }} -SkipAsSource $true
{% endif %}

{% if (interface.connection) and (interface.connection.mtu is defined) %}
{% endif %}

{% if (dns_servers is defined) and (dns_servers != []) %}
Set-DnsClientServerAddress -InterfaceAlias $Interface -ServerAddresses {{ dns_servers | join(', ') }}
{% endif %}

{% if (dns_servers6 is defined) and (dns_servers6 != []) %}
Set-DnsClientServerAddress -InterfaceAlias $Interface -ServerAddresses {{ dns_servers6 | join(', ') }}
{% endif %}

{% endfor %}