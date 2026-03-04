# Vault Role

HashiCorp Vault native installation with Raft HA cluster support.

## Requirements

- Ubuntu 20.04/22.04/24.04
- Minimum 3 nodes for HA cluster
- External disk mounted at `/mnt/data01`

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `vault_version` | `1.15.4` | Vault version |
| `vault_data_dir` | `/mnt/data01/vault` | Data directory |
| `vault_api_port` | `8200` | API port |
| `vault_cluster_port` | `8201` | Cluster port |
| `vault_tls_disable` | `true` | Disable TLS (initial setup) |
| `vault_ui_enabled` | `true` | Enable Web UI |

## Usage

```yaml
- hosts: vault
  become: yes
  roles:
    - vault
```

## Post-Installation

Initialize Vault (run once on leader):

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
vault operator init -key-shares=5 -key-threshold=3
```

Unseal each node:

```bash
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>
```

## Cluster Status

```bash
vault status
vault operator raft list-peers
```

## Access

- **UI:** `http://<vault-ip>:8200/ui`
- **API:** `http://<vault-ip>:8200`
