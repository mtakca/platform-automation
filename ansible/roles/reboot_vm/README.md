# Reboot VM Role

## Description
Safely reboots target VMs and waits for them to come back online.

## Requirements
- SSH access to target hosts

## Usage
```bash
ansible-playbook -i inventories/uat/myenv/hosts.yaml playbooks/reboot-vm.yaml
```

## Author
DevOps Team
