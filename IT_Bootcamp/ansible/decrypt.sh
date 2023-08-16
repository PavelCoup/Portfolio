#!/bin/bash
# Расшифровка файла и сохранение его содержимого в новом файле
ansible-vault decrypt encrypted_inventory.yaml \
    --output inventory.yaml \
    --vault-password-file vault_pass.txt

ansible-vault decrypt encrypted_vars.yaml \
    --output vars.yaml \
    --vault-password-file vault_pass.txt



# Просмотр содержимого зашифрованного файла
# ansible-vault view encrypted_file.yml --ask-vault-pass