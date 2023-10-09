#!/bin/bash

set -e

# Generating new SSH host keys and machine-id if current SSH keys do not contain machine's hostname
if [[ -z $(grep -r {{ hostname }} /etc/ssh/) ]]; then

    echo "Regenerating SSH host keys and machine-id"

    # Reming existing SSH host keys
    rm /etc/ssh/ssh_host_* -v

    # Regenerate SSH host keys and machine-id on first boot
    ssh-keygen -A
    dbus-uuidgen --ensure=/etc/machine-id

    # Restarting SSH service
    systemctl restart ssh* # * Is to match sshd and ssh

else

    echo "done"

fi