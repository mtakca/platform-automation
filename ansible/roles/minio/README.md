# MinIO Ansible Role

This role installs and configures MinIO Object Storage. It supports **Single Drive** and **Distributed (Multi-Drive/Multi-Node)** modes.

## Features

- **Single Node Mode**: Standalone MinIO server.
- **Distributed Mode**: High availability with erasure coding.
- **Data Disk Support**: Uses `/mnt/data01/minio` for storage.
- **Systemd Hardening**: `ReadWritePaths` restricted to data directory.

## Requirements

- Ubuntu 20.04+

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `minio_version` | `latest` | MinIO version |
| `minio_root_user` | `minioadmin` | Root username |
| `minio_root_password` | `minioadmin` | Root password |
| `minio_volumes` | `/mnt/data01/minio` | Storage path(s) |

## Data Directories

- **Data**: `{{ minio_data_dir }}` (Default: `/mnt/data01/minio`)

## Example Playbook

```yaml
- hosts: minio
  roles:
    - role: minio
      vars:
        minio_root_password: "secure_password"
```
