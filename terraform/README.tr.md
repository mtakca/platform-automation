# Altyapı Terraform Çekirdeği

Bu dizin, `terraform/modules` altındaki modülleri kullanarak gerçek ortam mimarilerini (UAT, Prod, Example vb.) hazırlayan merkezi omurgadır.

## Orkestrasyon Akışı

```mermaid
sequenceDiagram
    participant Eng as DevOps Mühendisi
    participant Make as Makefile
    participant TF as Terraform Core
    participant vCD as Cloud Engine
    
    Eng->>Make: make apply ENV=example APP=myapp
    Make->>Make: Token Üret (Python/API)
    Make->>TF: terraform workspace select example-myapp
    Make->>TF: terraform apply -var-file=...
    TF->>vCD: API Çağrıları (Ağ, VM, FW Oluştur)
    vCD-->>TF: State ve IP Çıktıları
    TF-->>Make: Tamamlanma Sinyali (+ VM Hazırlık Kontrolü)
    Make->>Make: Ansible Tetikle
```

## Kullanım

Bu dizin kök altyapı konfigürasyonunu içerir. Değişkenler, merkezi `environments/` dizininden kök `Makefile` tarafından dinamik olarak enjekte edilir.

`terraform apply` komutunu elle çalıştırmanıza gerek yoktur. Monorepo kök dizinine gidin ve çalıştırın:

```bash
make apply ENV=example APP=myapp
```
