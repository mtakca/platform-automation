# Ansible Playbooks

This directory contains the playbooks used to orchestrate the infrastructure configuration.

## Main Playbooks

| Playbook | Description |
| :--- | :--- |
| **`site.yaml`** | **Master Playbook**. Runs all other playbooks in the correct order. |
| `setup_common.yaml` | Applies common configurations (packages, timezone, users) to all nodes. |
| `setup_ha_services.yaml` | **Master HA Playbook**. Imports individual deployment playbooks. |
| `setup_management.yaml` | Configures management services (Foreman, Landscape, WSUS). |
| `setup_k8s_cluster.yaml` | Runs Kubespray to install Kubernetes. |
| `deploy-minio.yaml` | Deploys MinIO Cluster. |
| `deploy-redis.yaml` | Deploys Redis Sentinel Cluster. |
| `deploy-kafka.yaml` | Deploys Kafka Cluster. |
| `deploy-rabbitmq.yaml` | Deploys RabbitMQ Cluster. |
| `deploy-postgresql-autobase.yaml` | Deploys PostgreSQL HA (Patroni) via Autobase. |
| `deploy-couchbase.yaml` | Deploys Couchbase Cluster. |
| `deploy-haproxy.yaml` | Deploys HAProxy + Keepalived. |

## Utility Playbooks

| Playbook | Description |
| :--- | :--- |
| `reboot.yml` | Reboots specified hosts. |
| `add-key.yml` | Adds SSH keys to hosts. |
| `remove-key.yml` | Removes SSH keys from hosts. |
| `deploy-landscape.yaml` | Standalone playbook for Landscape (integrated into `setup_management.yaml`). |
| `deploy-minio.yaml` | Standalone playbook for MinIO (integrated into `setup_ha_services.yaml`). |

## Usage

To run the entire infrastructure setup:

```bash
# From infra-terraform-core root
make ansible-apply ENV=p4
```

To run a specific playbook manually:

```bash
# From infra-ansible root
ansible-playbook playbooks/setup_ha_services.yaml -i inventories/p4/hosts.ini
```
