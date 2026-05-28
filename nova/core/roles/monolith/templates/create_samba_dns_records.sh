#!/usr/bin/env bash

set -e

SERVICE_RECORDS=(
    "{{ monolith_providentia_fqdn.split('.')[0] }}|{{ ad_domain_name }}|{{ connection_address }}|{{ 'A' if connection_address is ansible.utils.ipv4 else 'AAAA' }}"
    "{{ monolith_nexus_fqdn.split('.')[0] }}|{{ ad_domain_name }}|{{ connection_address }}|{{ 'A' if connection_address is ansible.utils.ipv4 else 'AAAA' }}"
    "{{ monolith_keycloak_fqdn.split('.')[0] }}|{{ ad_domain_name }}|{{ connection_address }}|{{ 'A' if connection_address is ansible.utils.ipv4 else 'AAAA' }}"
    "{{ monolith_vault_fqdn.split('.')[0] }}|{{ ad_domain_name }}|{{ connection_address }}|{{ 'A' if connection_address is ansible.utils.ipv4 else 'AAAA' }}"
)
EXTRA_RECORDS=(
    {% if monolith_extra_dns_records != [] %}
    {% for record in monolith_extra_dns_records %}
    "{{ record.host }}|{{ record.domain }}|{{ record.address }}|{{ 'A' if record.address is ansible.utils.ipv4 else 'AAAA' }}"
    {% endfor %}
    {% endif %}
)

DNS_RECORDS=("${SERVICE_RECORDS[@]}" "${EXTRA_RECORDS[@]}")
for record in "${DNS_RECORDS[@]}"
do
    RECORD_HOST=$(echo "$record" | awk -F'|' '{print $1}')
    RECORD_DOMAIN=$(echo "$record" | awk -F'|' '{print $2}')
    RECORD_ADDRESS=$(echo "$record" | awk -F'|' '{print $3}')
    RECORD_TYPE=$(echo "$record" | awk -F'|' '{print $4}')
    if host "$RECORD_HOST.$RECORD_DOMAIN" | grep -q "has.*address"; then
        echo "DNS record for $RECORD_HOST.$RECORD_DOMAIN already exists."
    else
        echo "Creating DNS record for $RECORD_HOST.$RECORD_DOMAIN..."
        echo "Adding DNS records - $RECORD_TYPE $RECORD_HOST.$RECORD_DOMAIN -> $RECORD_ADDRESS"
        samba-tool dns add "{{ hostname }}" "$RECORD_DOMAIN" "$RECORD_HOST" "$RECORD_TYPE" "$RECORD_ADDRESS" --username="{{ domain_netbios }}\\{{ domain_admin_username }}" --password="{{ domain_admin_password }}"
    fi
done
