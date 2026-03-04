# NFS Client Role

## Description
Mounts NFS shares on client hosts.

## Requirements
- NFS server accessible from client
- nfs-common package

## Role Variables

**Required (from inventory):**
```yaml
nfs_mounts:
  - src: "10.x.x.x:/export/path"
    dest: "/mnt/nfs"
    opts: "rw,sync"
```

## Usage
```bash
ansible-playbook -i environments/uat/myapp.ini playbooks/deploy-nfs-client.yaml
```

## Author
DevOps Team
