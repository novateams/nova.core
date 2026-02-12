#!/usr/bin/env bash

set -e

#########
# Users #
#########

USER_DETAILS=(
    {% for user in domain_user_accounts %}
    "{{ user.username }}"
    {% endfor %}
)

for USERNAME in "${USER_DETAILS[@]}"; do
    samba-tool user show $USERNAME | grep distinguishedName: | cut -d ":" -f2 | xargs
done
