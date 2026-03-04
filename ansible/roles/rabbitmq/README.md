# RabbitMQ Role

## Description
Deploys and configures RabbitMQ cluster using Docker Compose with optional HA via Keepalived.

## Requirements
- Docker and Docker Compose installed on target hosts
- External disk mounted at `/mnt/data01`

## Role Variables

**Required (set in inventory):**
```yaml
rabbitmq_erlang_cookie: ""      # Cluster secret
rabbitmq_admin_password: ""     # Admin user password
rabbitmq_vhost: ""              # Application vhost
rabbitmq_app_user: ""           # Application username
rabbitmq_app_password: ""       # Application password
```

**Optional:**
```yaml
rabbitmq_image_tag: "3.13-management-alpine"
rabbitmq_data_dir: "/mnt/data01/rabbitmq"
rabbitmq_management_port: 15672
rabbitmq_amqp_port: 5672
rabbitmq_keepalived_enabled: true
```

## Example Inventory
```yaml
rabbitmq:
  vars:
    rabbitmq_erlang_cookie: "MY_SECRET"
    rabbitmq_admin_password: "DefaultPassword123!"
    rabbitmq_vhost: "myapp"
    rabbitmq_app_user: "myapp"
    rabbitmq_app_password: "DefaultPassword123!"
```

## Usage
```bash
ansible-playbook -i inventories/uat/myenv/rabbitmq/hosts.yaml playbooks/deploy-rabbitmq.yaml
```

## HA Configuration
When `rabbitmq_is_ha: true` (auto-detected from inventory), the role will:
1. Join non-master nodes to cluster
2. Configure Keepalived VIP (if `rabbitmq_keepalived_enabled: true`)

## Author
DevOps Team
