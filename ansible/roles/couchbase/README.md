# Couchbase Ansible Role

This role installs and configures Couchbase Server. It handles **Cluster Initialization**, **Server Adding**, and **Rebalancing**.

## Features

- **Single Node Mode**: Initializes a standalone cluster.
- **HA Mode**:
  - Master node initializes the cluster.
  - Worker nodes join the cluster automatically.
  - Master node triggers rebalance.
- **Data Disk Support**:
  - Data: `/mnt/data01/couchbase/data`
  - Index: `/mnt/data02/couchbase/index` (Performance optimization)
- **OS Tuning**: Disables THP and Swappiness.

## Requirements

- Ubuntu 20.04+
- System resources (Min 4GB RAM recommended)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `couchbase_version` | `7.2.0` | Couchbase version |
| `couchbase_is_ha` | `false` | Enable HA Cluster mode |
| `couchbase_cluster_master` | `couchbase-01` | Master node hostname |
| `couchbase_admin_user` | `Administrator` | Admin username |
| `couchbase_admin_password` | `password` | Admin password |
| `couchbase_cluster_ram_size` | `1024` | Data RAM Quota (MB) |

## Data Directories

- **Data**: `{{ couchbase_data_dir }}`
- **Index**: `{{ couchbase_index_dir }}`

## Example Playbook

```yaml
- hosts: couchbase
  roles:
    - role: couchbase
      vars:
        couchbase_is_ha: true
        couchbase_cluster_ram_size: 2048
```
