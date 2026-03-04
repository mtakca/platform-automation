#!/bin/bash
# VM initialization script
# Based on working reference vm_init.sh

set -x  # Enable debug mode
exec > >(tee -a /var/log/vm-init.log) 2>&1

echo "=== VM Initialization Started at $(date) ==="
