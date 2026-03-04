# FreeIPA Role

Installs and configures FreeIPA Server for centralized identity management (LDAP, Kerberos, DNS).

## Features

- **External Disk Support**: Automatically uses `/mnt/data01` if available
- **DNS Integration**: Optional DNS server setup with forwarders
- **Unattended Installation**: Full automation via `ipa-server-install`
- **Firewall Configuration**: Configures UFW for required ports

## Requirements

- Ubuntu 22.04+
- At least 4GB RAM
- External disk at `/mnt/data01` (optional, recommended)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `freeipa_domain` | `p.local` | IPA domain |
| `freeipa_realm` | `P.LOCAL` | Kerberos realm |
| `freeipa_admin_password` | vault | Admin password |
| `freeipa_ds_password` | vault | Directory Server password |
| `freeipa_setup_dns` | `true` | Setup integrated DNS |
| `freeipa_forwarders` | `[8.8.8.8, 1.1.1.1]` | DNS forwarders |

## Disk Usage

| Path | Purpose |
|------|---------|
| `/mnt/data01/ipa` | IPA data (symlinked from `/var/lib/ipa`) |

## Usage

```bash
ansible-playbook playbooks/deploy-freeipa.yaml -i inventories/p1/devops.ini
```

## Post-Installation

1. Access Web UI: `https://<hostname>.p.local`
2. Admin user: `admin`
3. Add clients: `ipa-client-install --domain=p.local`
