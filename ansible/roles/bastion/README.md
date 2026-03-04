# Bastion Role

SSH jump host with security hardening (Fail2Ban, auditd, SSH hardening).

## Requirements

- Ubuntu 20.04/22.04/24.04

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `bastion_ssh_port` | `22` | SSH port |
| `bastion_fail2ban_maxretry` | `5` | Max failed attempts |
| `bastion_fail2ban_bantime` | `3600` | Ban duration (seconds) |
| `bastion_fail2ban_findtime` | `600` | Time window |
| `bastion_max_auth_tries` | `3` | SSH max auth tries |
| `bastion_idle_timeout` | `300` | Idle timeout (seconds) |
| `bastion_banner_text` | `"Authorized access only"` | Login banner |

## Usage

```yaml
- hosts: bastion
  become: yes
  roles:
    - bastion
```

## Features

- ✅ Fail2Ban (SSH brute-force protection)
- ✅ Auditd (audit logging)
- ✅ SSH hardening (no root, no password)
- ✅ Login banner
- ✅ Agent forwarding enabled

## Access

```bash
ssh -J example@<bastion-ip> example@<internal-ip>
```
