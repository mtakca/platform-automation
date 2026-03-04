# HAProxy Ansible Role

This role installs and configures HAProxy for load balancing. In HA mode, it configures **Keepalived** for VIP (Virtual IP) failover.

## Features

- **Single Node Mode**: Standalone HAProxy.
- **HA Mode**: Active/Passive pair with Keepalived VIP.
- **Dynamic Config**: Automatically discovers backend servers from Ansible inventory.
- **Stats Page**: Enabled by default on port 8404.

## Requirements

- Ubuntu 20.04+

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `haproxy_is_ha` | `false` | Enable HA (Keepalived) |
| `haproxy_vip` | `10.134.10.100` | Virtual IP address |
| `haproxy_vip_interface` | `ens192` | Network interface for VIP |
| `haproxy_priority` | `100` | Keepalived priority (Master > Backup) |

## Example Playbook

```yaml
- hosts: haproxy
  roles:
    - role: haproxy
      vars:
        haproxy_is_ha: true
        haproxy_vip: "10.134.10.200"
```
