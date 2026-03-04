# Keepalived Role

## Description
Configures Keepalived for VRRP-based high availability with customizable health check scripts.

## Requirements
- Ubuntu/Debian target hosts
- At least 2 nodes for HA

## Role Variables

**Required (from inventory):**
```yaml
keepalived_vip: ""             # Virtual IP address
keepalived_vrid: ""            # VRRP Router ID (unique per cluster)
keepalived_check_script: ""    # Health check command
keepalived_priority: 100       # Node priority (100=MASTER, 90=BACKUP)
```

**Optional:**
```yaml
keepalived_interface: "ens192"
```

## Example Inventory
```yaml
all:
  hosts:
    node-01:
      keepalived_priority: 100
    node-02:
      keepalived_priority: 90
  children:
    myservice:
      vars:
        keepalived_vip: "10.x.x.10"
        keepalived_vrid: 10
        keepalived_check_script: "curl -sf http://localhost:8080/health"
```

## Usage
```bash
ansible-playbook -i environments/uat/myapp.ini playbooks/deploy-keepalived.yaml
```

## Author
DevOps Team
