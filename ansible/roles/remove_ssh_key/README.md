# Remove SSH Key Role

## Description
Removes SSH public keys from target hosts.

## Requirements
- SSH access to target hosts

## Role Variables

**Required:**
```yaml
ssh_keys_to_remove:
  - user: "myuser"
    key: "ssh-rsa AAAA..."
```

## Usage
```bash
ansible-playbook -i inventories/uat/myenv/hosts.yaml playbooks/remove-ssh-key.yaml -e @keys.yaml
```

## Author
DevOps Team
