# ansible playbooks

You will need a password for ansible vault

## For testing, edit the list of roles in test_playbook.yaml

```bash
ansible-playbook -i <ip>, test_playbook.yaml -u <user> --ask-pass --ask-become-pass
```

## Set up user and keys

```bash
ansible-playbook new_user_playbook.yaml -i encrypted_inventory.yaml \
    --extra-vars "@encrypted_extra-vars-default-user.yaml" \ # We reduce the variables from the inventory and use the user by default until we have their own
    --ask-vault-pass # manual password entering when starting
    # --vault-password-file vault_pass.txt # File with password
```

## Set up other roles

```bash
ansible-playbook main_playbook.yaml -i encrypted_inventory.yaml \
    --ask-vault-pass # manual password entering when starting
    # --vault-password-file vault_pass.txt # File with password
```

## Set up kubernetes

```bash
ansible-galaxy install -r requirements.yml && \
ansible-playbook main_playbook.yaml encrypted_inventory.yaml \
    --limit kube \
    --ask-vault-pass # manual password entering when starting
    # --vault-password-file vault_pass.txt # File with password
```

- ansible 2.10.8
- python version = 3.10.6
