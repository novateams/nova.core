#!/usr/bin/env bash

set -e

SERVICE_RECORDS=(
    "{{ monolith_providentia_fqdn.split('.')[0] }}|{{ monolith_providentia_fqdn }}"
    "{{ monolith_nexus_fqdn.split('.')[0] }}|{{ monolith_nexus_fqdn }}"
    "{{ monolith_keycloak_fqdn.split('.')[0] }}|{{ monolith_keycloak_fqdn }}"
    "{{ monolith_vault_fqdn.split('.')[0] }}|{{ monolith_vault_fqdn }}"
)

CONNECTION_IPV4_FAMILY="{{ connection_address is ansible.utils.ipv4 }}"

for record in "${SERVICE_RECORDS[@]}"
do

    IFS='|' read -r host fqdn <<< "$record"
    if host "$fqdn" | grep -q "has.*address"; then
        echo "DNS record for $fqdn already exists."
    else
        echo "Creating DNS record for $fqdn..."
        if [ "$CONNECTION_IPV4_FAMILY" == "True" ]; then
            RECORD_TYPE="A"
        else
            RECORD_TYPE="AAAA"
        fi
        echo "Adding DNS records - $RECORD_TYPE $fqdn -> {{ connection_address }}"
        samba-tool dns add "{{ hostname }}" "{{ ad_domain_name }}" "$host" "$RECORD_TYPE" "{{ connection_address }}" --username="{{ domain_netbios }}\\{{ domain_admin_username }}" --password="{{ domain_admin_password }}"
    fi
done