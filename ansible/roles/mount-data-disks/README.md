# Mount Data Disks Role

## Description
Discovers, partitions, formats, and mounts additional data disks on target hosts.

## Requirements
- Unformatted disks attached to VMs
- Root/sudo access

## Role Variables

**Optional:**
```yaml
mount_path: "/data"            # Default mount path prefix
```

## Behavior
1. Discovers unformatted disks (/dev/sdb, /dev/sdc, etc.)
2. Creates GPT partition
3. Formats with XFS
4. Mounts to `/mnt/data01`, `/mnt/data02`, etc.
5. Adds to /etc/fstab for persistence

## Usage
```bash
ansible-playbook -i environments/uat/myapp.ini playbooks/deploy-mount-disks.yaml
```

## Author
DevOps Team
