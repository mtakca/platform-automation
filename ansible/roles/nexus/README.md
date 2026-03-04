# Nexus Role

Sonatype Nexus Repository Manager native installation.

## Requirements

- Ubuntu 20.04/22.04/24.04
- OpenJDK 8
- Minimum 4GB RAM, 8GB recommended
- External disk for data (recommended 250GB+)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `nexus_data_dir` | `/opt/sonatype-work` | Data directory |
| `nexus_version` | `latest` | Nexus version |

## Usage

```yaml
- hosts: nexus
  become: yes
  roles:
    - nexus
```

## Features

- ✅ OpenJDK 8 auto-install
- ✅ External disk auto-mount to `/opt/sonatype-work`
- ✅ Systemd service
- ✅ User isolation (nexus user)

## Post-Installation

1. Get initial admin password:
```bash
cat /opt/sonatype-work/nexus3/admin.password
```

2. Access UI and change password

## Access

- **UI:** `http://<nexus-ip>:8081`
- **Default user:** `admin`

## Repositories

After setup, create these repositories:
- `docker-hosted` (Docker private)
- `docker-proxy` (Docker Hub proxy)
- `maven-central` (Maven proxy)
- `npm-proxy` (NPM proxy)
