
$ErrorActionPreference = 'Stop'

# Removing existing IPs & Gateways
Get-NetIPAddress | Where-Object InterfaceAlias -NotLike Loopback* | Remove-NetIPAddress -Confirm:$false
Get-NetRoute | Where-Object InterfaceAlias -NotLike Loopback* | Remove-NetRoute -Confirm:$false

$Interfaces = @(Get-NetAdapter | Where-Object { $_.HardwareInterface -eq $true } | Select-Object -ExpandProperty Name | Sort-Object)

# Looping over Providentia interfaces
{% for interface in interfaces %}

{% set interface_loop = loop.index0 %}

# If no IP addresses are defined, enable DHCP and Router Discovery
{% if interface.addresses == [] %}
Set-NetIPInterface -InterfaceAlias $Interfaces[{{ interface_loop }}] -Dhcp Enabled -RouterDiscovery Enabled
Set-DnsClientServerAddress -InterfaceAlias $Interfaces[{{ interface_loop }}] -ResetServerAddresses
Restart-NetAdapter -Name $Interfaces[{{ interface_loop }}]
{% else %}
Set-NetIPInterface -InterfaceAlias $Interfaces[{{ interface_loop }}] `
-Dhcp {{ 'Enabled' if interface.addresses | map(attribute='mode') | intersect(['ipv4_dhcp']) else 'Disabled' }} `
-RouterDiscovery {{ 'Enabled' if interface.addresses | map(attribute='mode') | intersect(['ipv4_dhcp']) else 'Disabled' }}
Set-DnsClientServerAddress -InterfaceAlias $Interfaces[{{ interface_loop }}] -ResetServerAddresses

# Looping over IP addresses
{% if interface.addresses | map(attribute='mode') | intersect(['ipv4_static', 'ipv6_static']) | list | length > 0 %}
{% for ip_address in interface.addresses %}

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
{% endif %}

{% if dns_server_combined != [] %}
Set-DnsClientServerAddress -InterfaceAlias $Interfaces[{{ interface_loop }}] -ServerAddresses {{ dns_server_combined | join(', ') }}
{% endif %}

{% endif %}

Restart-NetAdapter -Name $Interfaces[{{ interface_loop }}]
{% endfor %}