#!/bin/bash

set -e

# Generating new SSH host keys and machine-id if current SSH keys do not contain machine's hostname
if [[ -z $(grep -r {{ hostname }} /etc/ssh/) ]]; then

    echo "Regenerating SSH host keys and machine-id"

    # Removing existing SSH host keys
    rm /etc/ssh/ssh_host_* -v

    # Regenerate SSH host keys and machine-id
    ssh-keygen -A
    rm /etc/machine-id
    systemd-machine-id-setup

    # Restarting SSH service
    systemctl restart ssh* # * Is to match sshd and ssh

else

    echo "done"

fi