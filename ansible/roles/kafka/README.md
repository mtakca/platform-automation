# Kafka Ansible Role

This role deploys and configures Apache Kafka and Zookeeper in **Single** or **HA** mode.

## Features

- **Mode Support**: Single Node or Clustered (HA).
- **Data Disk**:
  - Data: `/mnt/data01/kafka`
  - Logs: `/mnt/data02/kafka-logs` (if available) or `/mnt/data01/kafka-logs`
- **Zookeeper**: Automatically installs and configures Zookeeper.
- **Security**: Runs as `kafka` user with Systemd hardening.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `kafka_heap_size` | `1G` | JVM Heap Size |
| `kafka_is_ha` | `false` | Enable HA Cluster mode |
| `kafka_zookeeper_connect` | `localhost:2181` | Zookeeper connection string |
    - role: kafka
      vars:
        kafka_heap_size: "4G"
        kafka_is_ha: true
```
