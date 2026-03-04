# OPNsense Ansible Role

Configures OPNsense firewall via API using `puzzle.opnsense` collection.

## Features

- **VLAN Routing**: Auto-configure inter-VLAN firewall rules
- **NAT**: Outbound NAT for internet access
- **K8s Support**: Rules for Pod and Service CIDRs
- **API-based**: No SSH required, pure API configuration

## Requirements

```bash
ansible-galaxy collection install puzzle.opnsense
```

## Prerequisites

1. Enable OPNsense API access:
   - System → Access → Users → Create API key
   - System → Settings → Administration → Enable API

2. Store credentials in vault:
   ```yaml
   vault_opnsense_api_key: "your-api-key"
   vault_opnsense_api_secret: "your-api-secret"
   ```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `opnsense_host` | - | OPNsense IP/hostname |
| `opnsense_api_key` | vault | API key |
| `opnsense_api_secret` | vault | API secret |
| `opnsense_vlans` | (see defaults) | VLAN topology |
| `opnsense_default_rules` | (see defaults) | Firewall rules |

## Usage

```bash
ansible-playbook playbooks/deploy-opnsense.yaml -i inventories/p1/core.ini
```

## Default Rules

| Rule | Source | Destination | Action |
|------|--------|-------------|--------|
| APP to DATA | 10.80.2.0/24 | 10.80.3.0/24 | Pass |
| APP to CACHE | 10.80.2.0/24 | 10.80.4.0/24 | Pass |
| DATA to CACHE | 10.80.3.0/24 | 10.80.4.0/24 | Pass |
| MGMT to ALL | 10.80.5.0/24 | 10.80.0.0/16 | Pass |
| DMZ to Internal | 10.80.1.0/24 | 10.80.0.0/16 | Block |
