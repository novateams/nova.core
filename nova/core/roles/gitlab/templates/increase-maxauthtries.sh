#!/bin/bash

FILE="/assets/sshd_config"
SEARCH_LINE="MaxAuthTries {{ gitlab_ssh_max_auth_tries }}"

# Check if MaxAuthTries already set
if grep -qF "$SEARCH_LINE" "$FILE"; then

    echo present

else

    echo added
    echo "$SEARCH_LINE" >> /assets/sshd_config

fi
