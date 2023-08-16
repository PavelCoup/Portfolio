#!/bin/bash

path=$(dirname "${BASH_SOURCE[0]}")
bash "$path"/encrypt.sh
ansible-playbook "$@" -i encrypted_inventory.yaml \
    --vault-password-file vault_pass.txt \
    --ssh-extra-args='-o StrictHostKeyChecking=no' 
    # --extra-vars "@encrypted_extra-vars-default-user.yaml"
    # --limit=ubuntu20ansible