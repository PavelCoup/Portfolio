#!/bin/bash

path=$(dirname "${BASH_SOURCE[0]}")
ansible-vault encrypt \
    --vault-password-file "$path"/vault_pass.txt "$path"/inventory.yaml \
    --output "$path"/encrypted_inventory.yaml
ansible-vault encrypt \
    --vault-password-file "$path"/vault_pass.txt "$path"/extra-vars-default-user.yaml \
    --output "$path"/encrypted_extra-vars-default-user.yaml 