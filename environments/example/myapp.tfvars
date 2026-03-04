###############################################
# ENVIRONMENT - Example Application Infrastructure
# Network: 10.0.10.0/24 (App-K8s VLAN)
###############################################

dc_prefix        = "example-dc"
environment_name = "example"
app_prefix       = "myapp"

###############################################
# NODE POOLS - Ordered by IP Range
###############################################

node_pools = {

  # ===========================================
  # KUBERNETES CLUSTER (10.0.10.11-30)
  # ===========================================

  k8s-controller = {
    role             = "k8s-controller"
    count            = 3
    ip_start_offset  = 11 # 10.0.10.11-13
    cpus             = 4
    memory           = 8192
    network_name     = "myapp-vnet"
    auto_mount_disks = true
    data_disks = {
      disk1 = { size_gb = 100, bus_number = 0, unit_number = 1, mount_path = "/mnt/data01" }
    }
  }

  k8s-worker = {
    role             = "k8s-worker"
    count            = 3
    ip_start_offset  = 21 # 10.0.10.21-23
    cpus             = 8
    memory           = 16384
    network_name     = "myapp-vnet"
    auto_mount_disks = true
    data_disks = {
      disk1 = { size_gb = 200, bus_number = 0, unit_number = 1, mount_path = "/mnt/data01" }
    }
  }

  # ===========================================
  # CORE SERVICES (10.0.10.51-100)
  # ===========================================

  # PostgreSQL HA Cluster (Autobase)
  postgresql = {
    role             = "postgresql"
    count            = 3
    ip_start_offset  = 51 # 10.0.10.51-53, VIP: .50
    cpus             = 8
    memory           = 16384
    network_name     = "myapp-vnet"
    auto_mount_disks = true
    data_disks = {
      disk1 = { size_gb = 500, bus_number = 0, unit_number = 1, mount_path = "/var/lib/postgresql" }
    }
  }

  # Redis Cluster
  redis = {
    role             = "redis"
    count            = 3
    ip_start_offset  = 61 # 10.0.10.61-63, VIP: .60
    cpus             = 4
    memory           = 8192
    network_name     = "myapp-vnet"
    auto_mount_disks = true
    data_disks = {
      disk1 = { size_gb = 50, bus_number = 0, unit_number = 1, mount_path = "/var/lib/redis" }
    }
  }

  # HAProxy Load Balancers
  haproxy = {
    role             = "haproxy"
    count            = 2
    ip_start_offset  = 71 # 10.0.10.71-72, VIP: .70
    cpus             = 4
    memory           = 4096
    network_name     = "myapp-vnet"
    auto_mount_disks = false
  }
}

###############################################
# HA CONFIGURATION (VIPs, Keepalived)
###############################################

service_config = {
  postgresql = {
    vip          = "10.0.10.50"
    vrid         = 50
    check_script = "pg_isready -U postgres"
    extra_vars   = {}
    host_vars    = {}
  }
  redis = {
    vip          = "10.0.10.60"
    vrid         = 60
    check_script = "redis-cli PING"
    extra_vars   = {}
    host_vars    = {}
  }
  haproxy = {
    vip          = "10.0.10.70"
    vrid         = 70
    check_script = "systemctl is-active haproxy"
    extra_vars   = {}
    host_vars    = {}
  }
}
