# Network Module

This module manages the creation and configuration of networks within a VMware Cloud Director (VCD) environment. It supports three types of networks to accommodate both Greenfield (new) and Brownfield (existing) deployments.

## Network Types

1.  **Routed (`type = "routed"`)**:
    *   Creates a new `vcd_network_routed` attached to a specified Edge Gateway.
    *   Used when Terraform manages the full network lifecycle and routing.
    *   **Requires:** Existing Edge Gateway.

2.  **Isolated (`type = "isolated"`)**:
    *   Creates a new `vcd_network_isolated`.
    *   Completely internal to the VDC/vApp, no internet access.
    *   Used for backend layers like Data and Cache.

3.  **Org Network (`type = "org"`)**:
    *   **Does NOT create a new network.**
    *   Assumes the network already exists in the Org VDC (e.g., pre-provisioned VLANs).
    *   Used for "Brownfield" scenarios where networks are provided by the Network Team.
    *   The module simply passes the name through so the vApp can attach to it.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|:--------:|
| `environment` | string | Deployment environment (e.g., `uat`, `prod`). | Yes |
| `dc_prefix` | string | Datacenter prefix (e.g., `34`). | Yes |
| `app_prefix` | string | Application prefix (e.g., `myapp`). | Yes |
| `edge_gateway` | string | Name of the Edge Gateway (required for `routed` networks). | Yes |
| `dns_servers` | list(string) | List of DNS servers. | No (Default: 1.1.1.1, 8.8.8.8) |
| `subnets` | map(object) | Configuration map for subnets. | Yes |

### Subnet Object Structure

```hcl
subnets = {
  "key" = {
    cidr        = "10.x.x.x/24"
    type        = "routed" | "isolated" | "org"
    name        = optional(string) # Override generated name (Crucial for 'org' type)
    gateway     = optional(string)
    dns_suffix  = optional(string)
    suffix      = optional(string)
    description = optional(string)
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| `network_names` | Map of logical keys (e.g., `app`) to actual VCD network names. |
| `network_cidrs` | Map of logical keys to CIDRs. |
| `routed_network_ids` | IDs of created routed networks. |
| `isolated_network_ids` | IDs of created isolated networks. |

## Usage Example

```hcl
module "network" {
  source = "../modules/network"

  environment  = "uat"
  dc_prefix    = "34"
  app_prefix   = "demo"
  edge_gateway = "T1-GW-01"

  subnets = {
    # Brownfield: Use existing VLAN
    "app" = {
      cidr = "10.0.1.0/24"
      type = "org"
      name = "EXISTING_VLAN_NAME"
    }
    # Greenfield: Create isolated network
    "db" = {
      cidr = "10.0.2.0/24"
      type = "isolated"
    }
  }
}
```
