# Foreman Ansible Role

This role installs and configures **Foreman** for lifecycle management and provisioning.

## Features

- **Foreman Installation**: Installs Foreman via official repositories.
- **Puppet Integration**: Configures Puppet master (optional).
- **Database**: Configures PostgreSQL for Foreman.

## Requirements

- Ubuntu 20.04+
- Minimum 4GB RAM.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `foreman_version` | `3.9` | Foreman version |
| `foreman_plugins` | `[]` | List of plugins to install |
| `foreman_admin_password` | `changeme` | Admin UI password |

## Example Playbook

```yaml
- hosts: foreman
  roles:
    - role: foreman
      vars:
        foreman_admin_password: "secure_password"
```
