#!/usr/bin/env python3
import sys
import re
import os

def parse_tfvars(env, app):
    # Try new structure first: environments/{env}/{app}.tfvars
    tfvars_path = f"environments/{env}/{app}.tfvars"
    if not os.path.exists(tfvars_path):
        # Fallback to old structure: environments/{env}.tfvars
        tfvars_path = f"environments/{env}.tfvars"
        if not os.path.exists(tfvars_path):
            print(f"Error: tfvars not found for env={env}, app={app}", file=sys.stderr)
            sys.exit(1)

    pools = {}
    dc_prefix = None
    environment_name = None
    app_prefix = None
    
    with open(tfvars_path, 'r') as f:
        content = f.read()

    # Extract dc_prefix, environment_name, app_prefix
    dc_match = re.search(r'dc_prefix\s*=\s*"([^"]+)"', content)
    env_match = re.search(r'environment_name\s*=\s*"([^"]+)"', content)
    app_match = re.search(r'app_prefix\s*=\s*"([^"]+)"', content)
    
    if dc_match:
        dc_prefix = dc_match.group(1)
    if env_match:
        environment_name = env_match.group(1)
    if app_match:
        app_prefix = app_match.group(1)

    # Find the node_pools block
    node_pools_match = re.search(r'node_pools\s*=\s*\{(.*?)\n\}', content, re.DOTALL)
    if not node_pools_match:
        return pools, dc_prefix, environment_name, app_prefix

    block_content = node_pools_match.group(1)
    
    current_pool = None
    
    for line in block_content.split('\n'):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
            
        # Check for pool start: key = {
        pool_match = re.match(r'(\S+)\s*=\s*\{', line)
        if pool_match:
            current_pool = pool_match.group(1)
            continue
            
        # Check for count inside a pool
        if current_pool:
            count_match = re.match(r'count\s*=\s*(\d+)', line)
            if count_match:
                pools[current_pool] = int(count_match.group(1))
                
        # Check for end of pool block
        if line == '}' or line == '},':
            current_pool = None

    return pools, dc_prefix, environment_name, app_prefix

def main():
    if len(sys.argv) < 3:
        # No targets specified, return empty
        return

    env = sys.argv[1]
    app = sys.argv[2] if len(sys.argv) > 3 else "devops"
    raw_args = sys.argv[3:] if len(sys.argv) > 3 else sys.argv[2:]
    
    # Normalize targets: handle spaces and commas
    targets = []
    for arg in raw_args:
        for t in arg.split(','):
            t = t.strip()
            if t:
                targets.append(t)
    
    pools, dc_prefix, environment_name, app_prefix = parse_tfvars(env, app)
    final_targets = []

    for t in targets:
        # Case 1: It's a pool name (e.g., "minio")
        if t in pools:
            count = pools[t]
            for i in range(1, count + 1):
                suffix = f"{i:02d}"
                # Use full VM naming convention
                vm_key = f"{dc_prefix}-{environment_name}-{app_prefix}-{t}-{suffix}"
                final_targets.append(f'module.vms["{vm_key}"]')
        
        # Case 2: It looks like a specific instance (e.g., "minio-01" or "34-p4-devops-minio-01")
        elif any(t.startswith(p + "-") for p in pools) or any(f"-{p}-" in t for p in pools):
             # If it's not already wrapped in module.vms, wrap it
             if not t.startswith("module."):
                 # If it doesn't have dc_prefix, add it
                 if not t.startswith(f"{dc_prefix}-"):
                     vm_key = f"{dc_prefix}-{environment_name}-{app_prefix}-{t}"
                 else:
                     vm_key = t
                 final_targets.append(f'module.vms["{vm_key}"]')
             else:
                 final_targets.append(t)
                 
        # Case 3: Raw target or unknown
        else:
            final_targets.append(t)

    # Print formatted for Makefile
    print(' '.join([f"-target='{ft}'" for ft in final_targets]))

if __name__ == "__main__":
    main()
