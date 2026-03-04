# Full-Stack Infrastructure Monorepo: Terraform & Ansible

This repository represents the full-stack infrastructure automation standard for deploying containerized platforms. It demonstrates the "Day 1" infrastructure provisioning via **Terraform** and the "Day 2" fine-grained configuration via **Ansible**, all stitched together with a centralized **Makefile**. This eliminates manual copy-pasting of IPs and tokens.

## Repository Structure

```tree
.
├── Makefile                    # The Central Orchestrator
├── environments/               # File-based Truth (State Hierarchy)
│   └── example/
│       ├── myapp.tfvars        # Environment-specific Terraform inputs
│       └── myapp.ini           # Environment-specific Ansible Inventory
├── scripts/                    # Automation Scripts
│   ├── get_token.py            # VCD OAuth2 token exchange
│   ├── expand_targets.py       # Makefile target expansion
│   ├── inventory.py            # TF → Ansible inventory generator
│   └── reboot_nodes.py         # VCD VM reboot utility
├── templates/                  # Shared Templates
│   └── service-inventory.yaml.tftpl
├── ansible/                    # Configuration Management
│   ├── playbooks/              # 50+ deployment playbooks
│   ├── roles/                  # 27 reusable roles
│   ├── group_vars/             # Group variable defaults
│   └── requirements.yaml       # Galaxy dependencies
├── terraform/                  # Infrastructure Configuration (Core)
│   ├── main.tf
│   ├── vms.tf                  # VM definitions + inventory output
│   ├── firewall_internal.tf    # OPNsense firewall rules
│   └── modules/                # Reusable IaC components
│       ├── base_vm_template/   # Generic VM module (Ubuntu/Windows)
│       ├── base_infra/         # vApp + Network baseline
│       ├── network/            # Routed/Isolated network management
│       └── vapp/               # vApp lifecycle management
└── k8s/                        # Kubernetes Manifests (Day 2+)
    ├── argocd/                 # GitOps — App-of-Apps pattern
    ├── crossplane/             # Self-service infrastructure (XRD/Compositions)
    ├── velero/                 # Backup & DR schedules
    ├── storage/                # StorageClass definitions (Portworx)
    ├── chaos/                  # Chaos Engineering experiments (ChaosMesh)
    └── security/               # Zero-Trust (Kyverno, Istio mTLS)
```

## The Makefile Orchestration Flow

Instead of maintaining brittle CI/CD integrations for multi-stage pipelines, we wrap the execution within a robust `Makefile` that handles variables explicitly through the `ENV` and `APP` parameters.

```bash
make apply ENV=example APP=myapp
```

This single command:
1. Validates or creates the `example-myapp` Terraform Workspace.
2. Reads properties from `environments/example/myapp.tfvars`.
3. Provisions infrastructure and outputs IPs.
4. Waits exactly 30 seconds for the network layers and SSH daemons to normalize.
5. Invokes Ansible using the strict inventory `environments/example/myapp.ini`.

## Kubernetes Day-2 Operations

The `k8s/` directory contains production-ready manifests for platform-level Kubernetes operations:

| Directory | Purpose | Article |
|---|---|---|
| `argocd/` | GitOps App-of-Apps root application | Part 5 |
| `crossplane/` | Self-service PostgreSQL via Crossplane XRDs | Part 5 |
| `velero/` | Hourly + daily backup schedules (MinIO backend) | Part 6 |
| `storage/` | Portworx StorageClasses (repl3 prod, repl1 dev) | Part 6 |
| `chaos/` | ChaosMesh experiments (Patroni kill, split-brain) | Part 6 |
| `security/` | Kyverno image signing + Istio strict mTLS | Part 7 |

## Development Principles

- **Zero Placeholders:** Ready-to-use production modules.
- **Fail-Safe Design:** Enforcing strict error handling (`set -euo pipefail` in scripts).
- **Separation of Concerns:** Terraform handles *only* structural infrastructure; Ansible handles *only* internal state.
- **GitOps Core:** Git is the single source of truth. ArgoCD reconciles desired state continuously.
- **Zero-Trust Security:** mTLS everywhere, signed images only, Policy-as-Code guardrails.
