#!/usr/bin/env bash

########################
# Organizational Units #
########################

{% if accounts_ou_list != [] %}
OUS=(
    {% for dn in accounts_ou_list %}
    "{{ dn.path }}"
    {% endfor %}
)

mapfile -t EXISTING_OUS < <(samba-tool ou list --full-dn)

for ou in "${OUS[@]}"
do
    # Check if the OU already exists
    if [[ " ${EXISTING_OUS[*]} " == *" $ou "* ]]; then
        echo "The organizational unit already exists - $ou"
    else
        echo "Creating $ou organizational unit..."
        samba-tool ou add "$ou"
    fi
done
{% endif %}

##########
# Groups #
##########

{% if domain_groups != [] %}
GROUPS_DETAILS=(
    {% for group in domain_groups %}
    "{{ group.name }}|{{ accounts_samba_group_scope_map[group.scope] | default('Global') }}|{{ group.description | default('Missing description') }}|{{ group.ou }}|{{ group.ou | regex_replace(',' ~ domain_dn, '') }}"
    {% endfor %}
)

mapfile -t EXISTING_GROUPS < <(samba-tool group list --full-dn)

for entry in "${GROUPS_DETAILS[@]}"
do
    IFS='|' read -r group scope description groupou group_path <<< "$entry"

    if [[ " ${EXISTING_GROUPS[*]} " == *"CN=$group,$groupou"* ]]; then
        echo "The group already exists - $group"
    else
        echo "Creating $group group..."
        samba-tool group add "$group" --groupou="$group_path" --description="$description" --group-scope="$scope"
    fi
done
{% endif %}

#########
# Users #
#########

{% if domain_users_with_password != [] %}
USER_DETAILS=(
    {% for user in domain_users_with_password %}
    "{{ user.username }}|{{ user.password }}|{{ user.groups | default([]) | join(',') }}|{{ user.update_password | default('always') }}|{{ user.ou | default('CN=Users,' ~ domain_dn) | regex_replace(',' ~ domain_dn, '') }}"
    {% endfor %}
)

mapfile -t EXISTING_USERS < <(samba-tool user list)

for entry in "${USER_DETAILS[@]}"
do
    IFS='|' read -r username password groups update_password userou <<< "$entry"
    if [[ " ${EXISTING_USERS[*]} " == *" $username "* ]]; then
        if [[ "$update_password" == "always" ]]; then
            echo "Updating password for $username user account..."
            samba-tool user setpassword --filter=samaccountname="$username" --newpassword="$password"
        else
            echo "The user account already exists - $username"
        fi
    else
        echo "Adding a new user $username to path $userou..."
        samba-tool user add "$username" "$password" --userou="$userou"
    fi
    if [[ -n "$groups" ]]; then
        IFS=',' read -ra group_array <<< "$groups"
        for group in "${group_array[@]}"
        do
            if ! samba-tool group listmembers "$group" | grep -q "^$username$"; then
            echo "Adding $username to $group group..."
            samba-tool group addmembers "$group" "$username"
            else
                echo "$username is already a member of $group group"
            fi
        done
    fi
done
{% endif %}

#################
# Group Members #
#################

{% if domain_groups != [] %}
GROUP_MEMBERS_DETAILS=(
    {% for group in domain_groups %}
    "{{ group.name }}|{{ group.members | default([]) | join(',') }}"
    {% endfor %}
)

for entry in "${GROUP_MEMBERS_DETAILS[@]}"
do
    IFS='|' read -r group members <<< "$entry"
    if [[ -n "$members" ]]; then
        IFS=',' read -ra member_array <<< "$members"
        for member in "${member_array[@]}"
        do
            if ! samba-tool group listmembers "$group" | grep -q "^$member$"; then
            echo "Adding $member to $group group..."
            samba-tool group addmembers "$group" "$member"
            else
                echo "$member is already a member of $group group"
            fi
        done
    fi
done
{% endif %}