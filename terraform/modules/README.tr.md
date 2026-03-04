# Terraform Modülleri

Bu dizin, VMware Cloud Director altyapısı için yeniden kullanılabilir Terraform modüllerini içerir. Modüller uygulama altyapısı, VM template'leri, ağ ve temel altyapı bileşenlerini soyutlar.

## Mevcut Modüller

- `app_infra`: vApp + VM'ler ile tam uygulama altyapısı oluşturur. Node pool tanımları desteklenir.
- `base_vm_template`: VM oluşturma için temel şablon; cloud-init / init scriptleri içerir.
- `network`: İzole ağlar ve CIDR tanımları için yardımcı modül.
- `vapp`, `base_infra` vb. diğer modüller altyapının katmanlarını sağlar.

## Kullanım

```hcl
module "app_infra" {
  source = "./modules/app_infra"

  org_name        = var.org_name
  vdc_name        = var.vdc_name
  catalog_name    = var.catalog_name
  template_name   = var.template_name
  storage_profile = var.storage_profile

  dc_prefix        = "34"
  app_prefix       = "devops"
  environment_name = "uat"

  node_pools = {
    web = {
      role            = "web"
      count           = 2
      ip_start_offset = 10
      cpus            = 2
      memory          = 4096
      network_name    = "app-vnet"
    }
  }
}
```

Değişkenler ve çıktıların tam tanımı her modülün `variables.tf` / `outputs.tf` dosyasında bulunmaktadır.

## Test & Geliştirme

```bash
cd modules/app_infra
terraform init
terraform validate
```

## Entegrasyon Notları

- Modüller `terraform/` dizini altındaki root konfigürasyon (`vms.tf`, `main.tf`) tarafından çağrılır.
- Modül çıktıları (VM IP'leri, isimler) toplanıp `templates/service-inventory.yaml.tftpl` ile Ansible envanteri oluşturulur.
- Modül çıktılarının beklenen formatta olması (ör. `vm_ip` alanı) önemlidir.

## Öneriler

- Her modül için örnek `usage` dosyası (minimal input setleri) eklenmeli.
- Değişken ve çıktı açıklamaları modül içinde eksiksiz doldurulmalı.
- Versioning: modül sürümlerini `ref` ile kullanmak için Git tag/semver politikası uygulanmalı.
- Modül testleri: `terratest` benzeri araçlarla doğrulama eklenmesi faydalı olur.
