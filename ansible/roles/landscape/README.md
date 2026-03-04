# Landscape Ansible Role

This role registers Ubuntu servers with **Canonical Landscape** for centralized management and patching.

## Features

- **Client Installation**: Installs `landscape-client`.
- **Registration**: Registers the machine with the Landscape server.
- **Script Execution**: Can run remote scripts via Landscape.

## Requirements

- Ubuntu 20.04+
- Existing Landscape Server account.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `landscape_account_name` | `standalone` | Landscape account name |
| `landscape_server_url` | `https://landscape.canonical.com/message-system` | Landscape server URL |
| `landscape_registration_key` | `secret_key` | Registration key |
| `landscape_tags` | `devops,server` | Tags to apply to the computer |

## Example Playbook

```yaml
- hosts: landscape
  roles:
    - role: landscape
      vars:
        landscape_registration_key: "my-secret-key"
```
