# Full-Stack Altyapı Monorepo: Terraform & Ansible

Bu repo, konteynerize platformların dağıtımı için tam yığın altyapı otomasyon standardını temsil eder. **Terraform** ile "Day 1" altyapı hazırlığını, **Ansible** ile "Day 2" konfigürasyonunu ve tüm bunları birleştiren merkezi **Makefile** orkestrasyon katmanını içerir.

## Repo Yapısı

```tree
.
├── Makefile                    # Merkezi Orkestratör
├── environments/               # Dosya Tabanlı Ortam Tanımları
│   └── example/
│       ├── myapp.tfvars        # Ortama özel Terraform değişkenleri
│       └── myapp.ini           # Ortama özel Ansible Envanteri
├── scripts/                    # Otomasyon Scriptleri
│   ├── get_token.py            # VCD OAuth2 token değişimi
│   ├── expand_targets.py       # Makefile hedef genişletme
│   ├── inventory.py            # TF → Ansible envanter üretici
│   └── reboot_nodes.py         # VCD VM yeniden başlatma aracı
├── templates/                  # Paylaşılan Şablonlar
│   └── service-inventory.yaml.tftpl
├── ansible/                    # Konfigürasyon Yönetimi
│   ├── playbooks/              # 50+ dağıtım playbook'u
│   ├── roles/                  # 27 yeniden kullanılabilir rol
│   ├── group_vars/             # Grup değişken varsayılanları
│   └── requirements.yaml       # Galaxy bağımlılıkları
├── terraform/                  # Altyapı Konfigürasyonu (Çekirdek)
│   ├── main.tf
│   ├── vms.tf                  # VM tanımları + envanter çıktısı
│   ├── firewall_internal.tf    # OPNsense firewall kuralları
│   └── modules/                # Yeniden kullanılabilir IaC bileşenleri
│       ├── base_vm_template/   # Jenerik VM modülü (Ubuntu/Windows)
│       ├── base_infra/         # vApp + Ağ temeli
│       ├── network/            # Routed/Isolated ağ yönetimi
│       └── vapp/               # vApp yaşam döngüsü yönetimi
└── k8s/                        # Kubernetes Manifestleri (Day 2+)
    ├── argocd/                 # GitOps — App-of-Apps deseni
    ├── crossplane/             # Self-service altyapı (XRD/Composition)
    ├── velero/                 # Yedekleme & DR zamanlamaları
    ├── storage/                # StorageClass tanımları (Portworx)
    ├── chaos/                  # Kaos Mühendisliği deneyleri (ChaosMesh)
    └── security/               # Zero-Trust (Kyverno, Istio mTLS)
```

## Makefile Orkestrasyon Akışı

Kırılgan CI/CD entegrasyonları yerine, tüm çalıştırmayı `ENV` ve `APP` parametreleri ile sağlam bir `Makefile` içinde yönetiyoruz.

```bash
make apply ENV=example APP=myapp
```

Bu tek komut:
1. `example-myapp` Terraform Workspace'ini doğrular veya oluşturur.
2. `environments/example/myapp.tfvars` dosyasından değişkenleri okur.
3. Altyapıyı hazırlar ve IP'leri çıktı olarak verir.
4. `wait_for_ready.yaml` çalıştırır — SSH bağlantısı, cloud-init tamamlanması ve disk mount'larını doğrular.
5. `environments/example/myapp.ini` envanterini kullanarak Ansible'ı çalıştırır.

## Kubernetes Day-2 Operasyonları

`k8s/` dizini, platform seviyesi Kubernetes operasyonları için production-ready manifestler içerir:

| Dizin | Amaç |
|---|---|
| `argocd/` | GitOps App-of-Apps root application |
| `crossplane/` | Crossplane XRD'leri ile self-service PostgreSQL |
| `velero/` | Saatlik + günlük yedekleme zamanlamaları (MinIO backend) |
| `storage/` | Portworx StorageClass'ları (repl3 prod, repl1 dev) |
| `chaos/` | ChaosMesh deneyleri (Patroni kill, split-brain) |
| `security/` | Kyverno image signing + Istio strict mTLS |

## Geliştirme Prensipleri

- **Sıfır Placeholder:** Kullanıma hazır production modülleri.
- **Hata Güvenli Tasarım:** Scriptlerde sıkı hata yönetimi (`set -euo pipefail`).
- **Sorumluluk Ayrımı:** Terraform *sadece* yapısal altyapı; Ansible *sadece* iç durum yönetimi.
- **GitOps Çekirdeği:** Git tek gerçeklik kaynağıdır. ArgoCD istenilen durumu sürekli uzlaştırır.
- **Zero-Trust Güvenlik:** Her yerde mTLS, sadece imzalı image'lar, Policy-as-Code koruma rayları.
