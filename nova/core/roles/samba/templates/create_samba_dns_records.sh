#!/usr/bin/env bash

set -e

DNS_RECORDS=(
    {% if samba_dns_records != [] %}
    {% for record in samba_dns_records %}
    "{{ record.host }}|{{ record.domain | default(ad_domain_name) }}|{{ record.address }}|{{ (record.type | default('A' if record.address is ansible.utils.ipv4 else 'AAAA' if record.address is ansible.utils.ipv6 else 'CNAME')) | upper }}"
    {% endfor %}
    {% endif %}
)

# Canonical form for exact comparison: lowercase, no trailing dot, compressed IPv6.
normalize() {
    local v="${1%.}"
    if [ "$RECORD_TYPE" = "AAAA" ]; then
        python3 -c 'import ipaddress,sys; print(ipaddress.ip_address(sys.argv[1]))' "$v" 2>/dev/null || echo "${v,,}"
    else
        echo "${v,,}"
    fi
}

for record in "${DNS_RECORDS[@]}"
do
    RECORD_HOST=$(echo "$record" | awk -F'|' '{print $1}')
    RECORD_DOMAIN=$(echo "$record" | awk -F'|' '{print $2}')
    RECORD_ADDRESS=$(echo "$record" | awk -F'|' '{print $3}')
    RECORD_TYPE=$(echo "$record" | awk -F'|' '{print $4}')
    SAMBA_AUTH=(--username="{{ domain_netbios }}\\{{ domain_admin_username }}" --password="{{ domain_admin_password }}")

    # Query the authoritative AD zone (not the resolver) for existing values of this name/type.
    mapfile -t EXISTING < <(samba-tool dns query "{{ hostname }}" "$RECORD_DOMAIN" "$RECORD_HOST" "$RECORD_TYPE" "${SAMBA_AUTH[@]}" 2>/dev/null \
        | awk -v t="$RECORD_TYPE:" '$1 == t {print $2}')

    WANTED=$(normalize "$RECORD_ADDRESS")
    FOUND=0
    STALE=()
    for value in "${EXISTING[@]}"; do
        if [ "$(normalize "$value")" = "$WANTED" ]; then
            FOUND=1
        else
            STALE+=("$value")
        fi
    done

    if [ "$FOUND" -eq 0 ]; then
        if [ -n "${STALE[*]}" ]; then
            echo "Updating DNS record - $RECORD_TYPE $RECORD_HOST.$RECORD_DOMAIN: ${STALE[0]} -> $RECORD_ADDRESS"
            samba-tool dns update "{{ hostname }}" "$RECORD_DOMAIN" "$RECORD_HOST" "$RECORD_TYPE" "${STALE[0]}" "$RECORD_ADDRESS" "${SAMBA_AUTH[@]}"
            STALE=("${STALE[@]:1}")
        else
            echo "Adding DNS record - $RECORD_TYPE $RECORD_HOST.$RECORD_DOMAIN -> $RECORD_ADDRESS"
            samba-tool dns add "{{ hostname }}" "$RECORD_DOMAIN" "$RECORD_HOST" "$RECORD_TYPE" "$RECORD_ADDRESS" "${SAMBA_AUTH[@]}"
        fi
    fi

    # Remove any other values so the name/type holds exactly the wanted record.
    for value in "${STALE[@]}"; do
        echo "Deleting stale DNS record - $RECORD_TYPE $RECORD_HOST.$RECORD_DOMAIN -> $value"
        samba-tool dns delete "{{ hostname }}" "$RECORD_DOMAIN" "$RECORD_HOST" "$RECORD_TYPE" "$value" "${SAMBA_AUTH[@]}"
    done

    if [ "$FOUND" -eq 1 ] && [ -z "${STALE[*]}" ]; then
        echo "DNS record $RECORD_TYPE $RECORD_HOST.$RECORD_DOMAIN -> $RECORD_ADDRESS already up to date."
    fi
done
