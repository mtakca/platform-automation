# Ağ Modülü

Bu modül, VMware Cloud Director (VCD) ortamında ağların oluşturulmasını ve konfigürasyonunu yönetir. Hem Greenfield (yeni) hem de Brownfield (mevcut) dağıtımlara uyum sağlamak için üç ağ tipini destekler.

## Ağ Tipleri

1. **Routed (`type = "routed"`)**:
   - Belirtilen Edge Gateway'e bağlı yeni bir `vcd_network_routed` oluşturur.
   - Terraform'un tam ağ yaşam döngüsünü ve yönlendirmeyi yönettiği durumlarda kullanılır.
   - **Gerekli:** Mevcut Edge Gateway.

2. **Isolated (`type = "isolated"`)**:
   - Yeni bir `vcd_network_isolated` oluşturur.
   - VDC/vApp'a tamamen dahili, internet erişimi yok.
   - Data ve Cache gibi arka uç katmanları için kullanılır.

3. **Org Network (`type = "org"`)**:
   - Yeni ağ **oluşturmaz**.
   - Ağın Org VDC'de zaten mevcut olduğunu varsayar (ör. önceden hazırlanmış VLAN'lar).
   - Ağların Network ekibi tarafından sağlandığı "Brownfield" senaryolarında kullanılır.
   - Modül, vApp'ın bağlanabilmesi için adı geçirir.

## Girdiler

| Ad | Tip | Açıklama | Zorunlu |
|---|---|---|:---:|
| `environment` | string | Dağıtım ortamı (ör. `uat`, `prod`). | Evet |
| `dc_prefix` | string | Veri merkezi öneki (ör. `34`). | Evet |
| `app_prefix` | string | Uygulama öneki (ör. `myapp`). | Evet |
| `edge_gateway` | string | Edge Gateway adı (`routed` ağlar için zorunlu). | Evet |
| `dns_servers` | list(string) | DNS sunucu listesi. | Hayır (Varsayılan: 1.1.1.1, 8.8.8.8) |
| `subnets` | map(object) | Alt ağ konfigürasyon haritası. | Evet |

### Alt Ağ Nesne Yapısı

```hcl
subnets = {
  "key" = {
    cidr        = "10.x.x.x/24"
    type        = "routed" | "isolated" | "org"
    name        = optional(string) # Üretilen adı geçersiz kıl ('org' tipi için kritik)
    gateway     = optional(string)
    dns_suffix  = optional(string)
    suffix      = optional(string)
    description = optional(string)
  }
}
```

## Çıktılar

| Ad | Açıklama |
|---|---|
| `network_names` | Mantıksal anahtarlardan (ör. `app`) gerçek VCD ağ adlarına harita. |
| `network_cidrs` | Mantıksal anahtarlardan CIDR'lara harita. |
| `routed_network_ids` | Oluşturulan routed ağların ID'leri. |
| `isolated_network_ids` | Oluşturulan isolated ağların ID'leri. |

## Kullanım Örneği

```hcl
module "network" {
  source = "../modules/network"

  environment  = "uat"
  dc_prefix    = "34"
  app_prefix   = "demo"
  edge_gateway = "T1-GW-01"

  subnets = {
    # Brownfield: Mevcut VLAN'ı kullan
    "app" = {
      cidr = "10.0.1.0/24"
      type = "org"
      name = "MEVCUT_VLAN_ADI"
    }
    # Greenfield: Izole ağ oluştur
    "db" = {
      cidr = "10.0.2.0/24"
      type = "isolated"
    }
  }
}
```
