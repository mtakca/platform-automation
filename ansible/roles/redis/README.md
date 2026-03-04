# Redis Ansible Role

This role installs and configures Redis in either **Single Node** or **HA (Sentinel)** mode.

## Features

- **Single Node Mode**: Standalone Redis server.
- **HA Mode**: Redis Sentinel cluster with Master/Replica replication.
- **Data Disk Support**: Automatically uses `/mnt/data01/redis` for data and `/mnt/data02/redis-logs` (if available) for logs.
- **Security Hardening**:
  - Runs as dedicated `redis` user.
  - Systemd `ReadWritePaths` hardening.
  - AppArmor profile overrides for custom data directories.
  - Protected mode enabled.

## Requirements

- Ubuntu 20.04+
- Ansible 2.9+

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `redis_port` | `6379` | Redis server port |
| `redis_bind` | `0.0.0.0` | Bind address |
| `redis_password` | `redis_password` | Authentication password |
| `redis_is_ha` | `false` | Enable HA (Sentinel) mode |
| `redis_master_ip` | `{{ ansible_host }}` | IP of the master node (for replicas) |
| `redis_sentinel_port` | `26379` | Sentinel port (HA only) |
| `redis_sentinel_quorum` | `2` | Quorum for failover (HA only) |

## Data Directories

The role dynamically assigns directories based on available disks:

- **Data**: `{{ redis_data_dir }}` (Default: `/mnt/data01/redis`)
- **Logs**: `{{ redis_log_dir }}` (Default: `/mnt/data02/redis/logs` or `/mnt/data01/redis/logs`)

## 🛠️ Example Playbook

```yaml
- hosts: redis
  roles:
    - role: redis
      vars:
        redis_password: "secure_password"
        redis_is_ha: true
```
