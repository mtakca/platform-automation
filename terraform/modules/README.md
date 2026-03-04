# Infrastructure Terraform Modules

This repository contains 100% modular, highly reusable, and production-ready infrastructure-as-code (IaC) modules meant for deploying standardized resources.

## Architecture

```mermaid
graph TD
  A[Terraform Core] -->|Invokes| B((Modules))
  B --> C[Network Module]
  B --> D[Base VM Module]
  B --> E[Firewall Module]
  C -.->|Example:| F[10.0.1.x/24 Network]
  D -.->|Example:| G[Ubuntu 22.04 VM]
```

## Core Principles

1. **Immutable Infrastructure:** Servers are treated as "cattle", not "pets".
2. **Generic Design:** Zero hardcoded company-specific IPs, private keys, or proprietary naming conventions.

## Usage
Refer to the `README.md` file within each specific module's directory for detailed usage instructions and input variables.