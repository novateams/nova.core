#!/bin/bash

VAULT_UNSEAL_KEY="{{ vault_unseal_key }}"

#----------End of variables, start of script----------#

while ! curl {{ vault_configuration_uri }}

do

  echo "Waiting until container is running"
  sleep 10

done

if sudo docker exec vault vault status; then

    echo "Vault is unsealed."

else

    echo "Vault is sealed!"
    echo "Unsealing..."
    sudo docker exec vault vault operator unseal $VAULT_UNSEAL_KEY

fi
