# Bind9 Role

## Description
Deploys and configures Bind9 DNS server with optional Master-Slave replication and Keepalived HA.

## Requirements
- Ubuntu/Debian target hosts
- External disk mounted at `/mnt/data01` (optional)

## Role Variables

**Required (from inventory):**
```yaml
bind9_mode: "master"           # master or slave
bind9_zones: []                # Zone definitions
```

**Optional:**
```yaml
bind9_listen_on: "any"
bind9_allow_query: "any"
bind9_forwarders:
  - "8.8.8.8"
  - "1.1.1.1"
```

## HA Configuration
Master-Slave with Keepalived VIP for automatic failover.

## Usage
```bash
ansible-playbook -i inventories/uat/devops/dns/hosts.yaml playbooks/deploy-bind9.yaml
```

## Author
DevOps Team
