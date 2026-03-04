# Init Scriptleri - Modüler Yapı

## Dizin Yapısı

```
templates/
├── scripts-ubuntu/          # Ubuntu/Debian init scriptleri
│   ├── 00-header.sh
│   ├── 10-users.sh.tftpl
│   ├── 20-network.sh.tftpl
│   ├── 30-hostname.sh.tftpl
│   ├── 40-ssh.sh.tftpl
│   ├── 50-disks.sh
│   └── 99-footer.sh
│
├── scripts-windows/         # Windows Server init scriptleri
│   ├── 00-header.ps1
│   ├── 10-hostname.ps1.tftpl
│   ├── 20-users.ps1.tftpl
│   ├── 30-network.ps1.tftpl
│   ├── 40-rdp.ps1
│   ├── 50-firewall.ps1
│   ├── 60-disks.ps1
│   ├── 70-winrm.ps1
│   ├── 80-optimizations.ps1
│   └── 99-footer.ps1
│
└── scripts-fedora-coreos/   # Fedora CoreOS (Ignition) - Gelecek
    └── (Planlandı - Ignition config)
```

## Script İsimlendirme Kuralı

- `00-header.*` - Başlatma, loglama kurulumu
- `10-hostname.*` - Hostname konfigürasyonu
- `20-users.*` - Kullanıcı yönetimi
- `30-network.*` - Ağ konfigürasyonu
- `40-*` - İşletim sistemine özel özellikler (SSH, RDP)
- `50-*` - Firewall, disk bağlama
- `60-70-*` - Ek servisler
- `80-*` - Optimizasyonlar
- `99-footer.*` - Temizlik, yeniden başlatma

## Kullanım

Scriptler `main.tf` içinde `is_windows` değişkenine göre otomatik olarak birleştirilir:

```hcl
initscript = var.is_windows ? join("\n", [
  # Windows scriptleri
  file("${path.module}/templates/scripts-windows/00-header.ps1"),
  ...
]) : join("\n", [
  # Ubuntu scriptleri
  file("${path.module}/templates/scripts-ubuntu/00-header.sh"),
  ...
])
```

## Yeni Script Ekleme

1. İlgili dizinde script oluşturun
2. İsimlendirme kuralına uyun (ör. `45-ozel-ozellik.ps1`)
3. `main.tf` dosyasına doğru sırada ekleyin
4. `terraform plan` ile test edin

## İşletim Sistemi Desteği

- ✅ **Ubuntu/Debian**: scripts-ubuntu (cloud-init)
- ✅ **Windows Server**: scripts-windows (cloud-init)
- 🚧 **Fedora CoreOS**: scripts-fedora-coreos (Ignition) - Planlandı
