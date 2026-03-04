# Ansible Playbook'ları

Bu dizin altyapı konfigürasyonunu orkestre etmek için kullanılan playbook'ları içerir.

## Ana Playbook'lar

| Playbook | Açıklama |
| :--- | :--- |
| **`site.yaml`** | **Ana Playbook**. Diğer tüm playbook'ları doğru sırada çalıştırır. |
| `setup_common.yaml` | Tüm düğümlere ortak konfigürasyonları (paketler, saat dilimi, kullanıcılar) uygular. |
| `setup_ha_services.yaml` | **Ana HA Playbook'u**. Münferit dağıtım playbook'larını import eder. |
| `setup_management.yaml` | Yönetim servislerini (Foreman, Landscape, WSUS) yapılandırır. |
| `setup_k8s_cluster.yaml` | Kubespray ile Kubernetes kurar. |
| `deploy-minio.yaml` | MinIO Kümesini dağıtır. |
| `deploy-redis.yaml` | Redis Sentinel Kümesini dağıtır. |
| `deploy-kafka.yaml` | Kafka Kümesini dağıtır. |
| `deploy-rabbitmq.yaml` | RabbitMQ Kümesini dağıtır. |
| `deploy-postgresql-autobase.yaml` | Autobase ile PostgreSQL HA (Patroni) dağıtır. |
| `deploy-couchbase.yaml` | Couchbase Kümesini dağıtır. |
| `deploy-haproxy.yaml` | HAProxy + Keepalived dağıtır. |
| `wait_for_ready.yaml` | Konfigürasyon öncesi SSH + cloud-init + disk mount bekler. |

## Yardımcı Playbook'lar

| Playbook | Açıklama |
| :--- | :--- |
| `reboot.yml` | Belirtilen sunucuları yeniden başlatır. |
| `add-key.yml` | Sunuculara SSH anahtarı ekler. |
| `remove-key.yml` | Sunuculardan SSH anahtarı kaldırır. |
| `deploy-landscape.yaml` | Landscape için bağımsız playbook (`setup_management.yaml` içine entegre). |

## Kullanım

Tüm altyapı kurulumunu çalıştırmak için:

```bash
# Monorepo kök dizininden
make ansible-site ENV=uat APP=myapp
```

Belirli bir playbook'u elle çalıştırmak için:

```bash
# Monorepo kök dizininden
ansible-playbook -i environments/uat/myapp.ini ansible/playbooks/setup_ha_services.yaml --become
```
