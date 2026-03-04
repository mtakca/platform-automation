# infra-terraform-modules (Türkçe)

Bu dizin, VMware Cloud Director altyapısı için yeniden kullanılabilir Terraform modüllerini içerir. Modüller uygulama altyapısı, VM template'leri, ağ ve temel altyapı bileşenlerini soyutlar.

Mevcut modüller (özet)
- `app_infra`: vApp + VM'ler ile tam uygulama altyapısı oluşturur. Node pool tanımları desteklenir.
- `base_vm_template`: VM oluşturma için temel şablon; cloud-init / init scriptleri içerir.
- `network`: İzole ağlar ve CIDR tanımları için yardımcı modül.
- `vapp`, `base_infra` vb. diğer modüller altyapının katmanlarını sağlar.

Kullanım (kısa örnek)

```hcl
module "app_infra" {
  source = "../infra-terraform-modules/modules/app_infra"

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

Değişkenler ve çıktıların tam tanımı her modülün `variables.tf` / `outputs.tf` dosyasında bulunmaktadır. Modül kullanırken input ve output isimlendirmelerine dikkat edin.

Test & Geliştirme

```bash
cd modules/app_infra
terraform init
terraform validate
```

Entegrasyon notları
- Modüller `infra-terraform-core` tarafından çağrılır. `core` tarafında modül çıktıları (ör. VM IP'leri, isimler) toplanıp Ansible envanteri oluşturulur.
- Modüllerin ürettiği çıktılar `infra-terraform-core` içinde toplanıp `templates/inventory.yaml.tftpl` ile dosya oluşturuluyor. Bu yüzden modül çıktılarının beklenen formatta olması (ör. vm ip alanı) önemlidir.

Eksikler / Öneriler
- Her modül için örnek `usage` dosyası (minimal input setleri) eklenmeli.
- Değişken ve çıktı açıklamaları modül içinde eksiksiz doldurulmalı.
- Versioning: modül sürümlerini `ref` ile kullanmak için Git tag/semver politikası uygulanmalı.
- Modül testleri: küçük bir integration testi veya `terratest` benzeri araçlarla doğrulama eklenmesi faydalı olur.

Lisans
- Dahili kullanım içindir.
