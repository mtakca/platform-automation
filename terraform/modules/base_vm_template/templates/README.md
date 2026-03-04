# Init Scripts - Modular Structure

## Directory Structure

```
templates/
├── scripts-ubuntu/          # Ubuntu/Debian init scripts
│   ├── 00-header.sh
│   ├── 10-users.sh.tftpl
│   ├── 20-network.sh.tftpl
│   ├── 30-hostname.sh.tftpl
│   ├── 40-ssh.sh.tftpl
│   ├── 50-disks.sh
│   └── 99-footer.sh
│
├── scripts-windows/         # Windows Server init scripts
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
└── scripts-fedora-coreos/   # Fedora CoreOS (Ignition) - Future
    └── (TBD - Ignition config)
```

## Script Naming Convention

- `00-header.*` - Initialization, logging setup
- `10-hostname.*` - Hostname configuration
- `20-users.*` - User management
- `30-network.*` - Network configuration
- `40-*` - OS-specific features (SSH, RDP)
- `50-*` - Firewall, disk mounting
- `60-70-*` - Additional services
- `80-*` - Optimizations
- `99-footer.*` - Cleanup, reboot

## Usage

Scripts are automatically assembled in `main.tf` based on `is_windows` variable:

```hcl
initscript = var.is_windows ? join("\n", [
  # Windows scripts
  file("${path.module}/templates/scripts-windows/00-header.ps1"),
  ...
]) : join("\n", [
  # Ubuntu scripts
  file("${path.module}/templates/scripts-ubuntu/00-header.sh"),
  ...
])
```

## Adding New Scripts

1. Create script in appropriate directory
2. Follow naming convention (e.g., `45-custom-feature.ps1`)
3. Add to `main.tf` in correct order
4. Test with `terraform plan`

## OS Support

- ✅ **Ubuntu/Debian**: scripts-ubuntu (cloud-init)
- ✅ **Windows Server**: scripts-windows (cloud-init)
- 🚧 **Fedora CoreOS**: scripts-fedora-coreos (Ignition) - Planned
