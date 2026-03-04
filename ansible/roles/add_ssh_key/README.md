# Add SSH Key Role

## Description
Adds SSH public keys to target hosts for user authentication.

## Requirements
- SSH access to target hosts

## Role Variables

**Required:**
```yaml
ssh_keys:
  - user: "myuser"
    key: "ssh-rsa AAAA..."
```

## Usage
```bash
ansible-playbook -i inventories/uat/myenv/hosts.yaml playbooks/add-ssh-key.yaml -e @keys.yaml
```

## Author
DevOps Team
