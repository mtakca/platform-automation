# Infrastructure Terraform Core

This repository acts as the central backbone that consumes modules from `terraform/modules` to provision entire real-world environment architectures (such as UAT, Prod, Example, etc.).

## Orchestration Flow

```mermaid
sequenceDiagram
    participant Eng as DevOps Engineer
    participant Make as Makefile
    participant TF as Terraform Core
    participant vCD as Cloud Engine
    
    Eng->>Make: make apply ENV=example APP=myapp
    Make->>Make: Generate Token (Python/API)
    Make->>TF: terraform workspace select example-myapp
    Make->>TF: terraform apply -var-file=...
    TF->>vCD: API Calls (Create Net, VM, FW)
    vCD-->>TF: State and IP Outputs
    TF-->>Make: Completion Signal (+ 30 sec wait)
    Make->>Make: Trigger Ansible (infra-ansible)
```

## Usage

This directory contains the root infrastructure configuration. Variables are injected dynamically by the root `Makefile` from the central `environments/` directory.

You do not need to run `terraform apply` manually. Navigate to the monorepo root and execute:

```bash
make apply ENV=example APP=myapp
```
