#!/bin/bash

set -e

#----------End of variables, start of script----------#

VAULT_UNSEAL_KEY="{{ vault_unseal_key }}"
CONTAINER_STATUS=$(sudo docker inspect -f {{ '{{.State.Running}}' }} {{ vault_container_name }})
SEAL_STATUS=$(sudo docker exec vault vault status | grep 'Sealed' | awk '{print $2}')

if [[ "$CONTAINER_STATUS" != "true" ]]; then

    echo "Waiting for 30 seconds for the container to start..."
    sleep 5

fi

if [[ "$CONTAINER_STATUS" != "true" ]]; then

    echo "Container is not running. Please start the container first."

elif [[ "$CONTAINER_STATUS" == "true" && "$SEAL_STATUS" == "false" ]]; then

    echo "Vault is already unsealed."

else

    echo "Unsealing Vault..."
    sudo docker exec vault vault operator unseal "$VAULT_UNSEAL_KEY"

fi
