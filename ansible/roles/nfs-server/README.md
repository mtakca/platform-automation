# NFS Server Role

## Description
Configures NFS server with customizable exports.

## Requirements
- Ubuntu/Debian target hosts
- External disk mounted for NFS exports

## Role Variables

**Required (from inventory):**
```yaml
nfs_exports:
  - path: "/mnt/data01/nfs"
    options: "*(rw,sync,no_subtree_check,no_root_squash)"
```

## Usage
```bash
ansible-playbook -i inventories/uat/myenv/nfs/hosts.yaml playbooks/deploy-nfs-server.yaml
```

## Author
DevOps Team
