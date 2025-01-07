
$ErrorActionPreference = 'Stop'

# Removing existing IPs & Gateways
Get-NetIPAddress | Where-Object InterfaceAlias -NotLike Loopback* | Remove-NetIPAddress -Confirm:$false
Get-NetRoute | Where-Object InterfaceAlias -NotLike Loopback* | Remove-NetRoute -Confirm:$false

# Looping over Providentia interfaces
{% for interface in interfaces %}

{% set interface_loop = loop.index -1 %}
$Interfaces = @(Get-NetAdapter | Select-Object -ExpandProperty Name | Sort-Object)

# Looping over IP addresses
{% for ip_address in interface.addresses %}

# Disabling DHCP and Router Discovery for the interface
Set-NetIPInterface -InterfaceAlias $Interfaces[{{ interface_loop }}] -Dhcp Disabled -RouterDiscovery Disabled

{% if (ip_address.mode == 'ipv4_static') and (ip_address.gateway != none) %}

# Excluding IPv4 gateway if it already exists
if ($null -eq (Get-NetIPConfiguration | Select-Object -ExpandProperty IPv4DefaultGateway)) {

    New-NetIPAddress -AddressFamily IPv4 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interfaces[{{ interface_loop }}] -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }} -DefaultGateway {{ ip_address.gateway }}

} else {

    New-NetIPAddress -AddressFamily IPv4 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interfaces[{{ interface_loop }}] -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }}
}

{% elif (ip_address.mode == 'ipv4_static') and (ip_address.gateway == none) %}
New-NetIPAddress -AddressFamily IPv4 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interfaces[{{ interface_loop }}] -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }}
{% endif %}

{% if (ip_address.mode == 'ipv6_static') and (ip_address.gateway != none) %}

# Excluding IPv6 gateway if it already exists
if ($null -eq (Get-NetIPConfiguration | Select-Object -ExpandProperty IPv6DefaultGateway)) {

    New-NetIPAddress -AddressFamily IPv6 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interfaces[{{ interface_loop }}] -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }} -DefaultGateway {{ ip_address.gateway }}

} else {

    New-NetIPAddress -AddressFamily IPv6 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interfaces[{{ interface_loop }}] -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }}
}

{% elif (ip_address.mode == 'ipv6_static') and (ip_address.gateway == none) %}
New-NetIPAddress -AddressFamily IPv6 -IPAddress {{ ip_address.address | ansible.utils.ipaddr('address') }} -InterfaceAlias $Interfaces[{{ interface_loop }}] -PrefixLength {{ ip_address.address | ansible.utils.ipaddr('prefix') }} -SkipAsSource $true
{% endif %}

{% endfor %}

{% if dns_server_combined != [] %}
Set-DnsClientServerAddress -InterfaceAlias $Interfaces[{{ interface_loop }}] -ServerAddresses {{ dns_server_combined | join(', ') }}
{% endif %}

{% endfor %}