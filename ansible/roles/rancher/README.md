# Rancher Role

## Description
Deploys Rancher Server using Docker with TLS certificate support.

## Requirements
- Docker installed on target host
- TLS certificates (optional)

## Role Variables

**Required (from inventory):**
```yaml
rancher_bootstrap_password: ""       # Initial admin password
rancher_hostname: ""                 # Rancher FQDN
```

**Optional:**
```yaml
rancher_image: "rancher/rancher:v2.9.2"
rancher_http_port: 80
rancher_https_port: 443
docker_data_root: "/mnt/data01/docker"
rancher_data_dir: "/mnt/data01/rancher"
```

## Usage
```bash
ansible-playbook -i environments/uat/myapp.ini playbooks/deploy-rancher.yaml
```

## Author
DevOps Team
