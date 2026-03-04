# Common Ansible Role


## 📋 Requirements

- Ubuntu 20.04+

## 🔧 Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `timezone` | `Europe/Istanbul` | System timezone |
| `create_users` | `true` | Whether to create default users |

## 🛠️ Example Playbook

```yaml
- hosts: all
  roles:
    - role: common
```
