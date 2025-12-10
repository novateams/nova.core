#!/bin/sh

set -e

# Generating new SSH host keys and machine-id if current SSH keys do not contain machine's hostname
if [ -z "$(grep -r {{ hostname }} /etc/ssh/)" ]; then

    echo "Regenerating SSH host keys and machine-id"

    # Removing existing SSH host keys
    rm /etc/ssh/ssh_host_* -v

    # Regenerate SSH host keys and machine-id
    ssh-keygen -A
    rm -f /etc/machine-id

    {% if ansible_facts.os_family | default(true) not in ["Alpine"] %}
    systemd-machine-id-setup

    # Restarting SSH service
    systemctl restart ssh* # * Is to match sshd and ssh
    {% endif %}

else

    echo "done"

fi