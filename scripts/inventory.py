#!/usr/bin/env python3
"""
Generate Ansible YAML inventory from Terraform outputs.

# Install dependency
pip install pyyaml


Usage:
    python inventory.py [--output FILE] [--terraform-dir DIR]

Examples:
    python inventory.py                              # Print to stdout
    python inventory.py --output inventory.yaml      # Write to file
    python inventory.py --terraform-dir ../code/wallet  # Specify terraform dir
"""
import argparse
import json
import subprocess
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML is required. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(1)


def get_terraform_output(terraform_dir=None):
    """Run terraform output and return the JSON."""
    try:
        cmd = ["terraform", "output", "-json"]
        kwargs = {
            "capture_output": True,
            "text": True,
            "check": True,
        }
        if terraform_dir:
            kwargs["cwd"] = terraform_dir

        result = subprocess.run(cmd, **kwargs)
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running terraform output: {e.stderr}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON output: {e}", file=sys.stderr)
        sys.exit(1)


def transform_to_yaml_inventory(tf_output):
    """Transform Terraform output to Ansible YAML inventory format."""
    inventory = {
        "all": {
            "children": {}
        }
    }

    if "ansible_inventory" not in tf_output:
        return inventory

    tf_inventory = tf_output["ansible_inventory"]["value"]
    hostvars = {}

    # Extract hostvars from _meta
    if "_meta" in tf_inventory and "hostvars" in tf_inventory["_meta"]:
        hostvars = tf_inventory["_meta"]["hostvars"]

    # Process each group
    for group_name, hosts in tf_inventory.items():
        if group_name == "_meta":
            continue

        group_data = {"hosts": {}}

        # hosts can be a list of hostnames
        if isinstance(hosts, list):
            for hostname in hosts:
                host_entry = {}
                # Add host variables if they exist
                if hostname in hostvars:
                    host_entry = hostvars[hostname]
                group_data["hosts"][hostname] = host_entry if host_entry else None
        elif isinstance(hosts, dict):
            # hosts might already be a dict with host details
            for hostname, host_vars in hosts.items():
                group_data["hosts"][hostname] = host_vars if host_vars else None

        inventory["all"]["children"][group_name] = group_data

    return inventory


def yaml_representer_none(dumper, _):
    """Represent None as empty value in YAML."""
    return dumper.represent_scalar('tag:yaml.org,2002:null', '')


def main():
    parser = argparse.ArgumentParser(
        description="Generate Ansible YAML inventory from Terraform outputs"
    )
    parser.add_argument(
        "--output", "-o",
        help="Output file path (default: stdout)"
    )
    parser.add_argument(
        "--terraform-dir", "-d",
        help="Directory containing Terraform state (default: current dir)"
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="Output JSON format (for dynamic inventory compatibility)"
    )
    parser.add_argument(
        "--host",
        help="Get variables for a specific host (for dynamic inventory)"
    )

    args = parser.parse_args()

    # Handle dynamic inventory mode (--list / --host)
    if args.list:
        tf_output = get_terraform_output(args.terraform_dir)
        inventory = transform_to_yaml_inventory(tf_output)
        # Convert to JSON dynamic inventory format
        json_inventory = {"_meta": {"hostvars": {}}}
        for group_name, group_data in inventory.get("all", {}).get("children", {}).items():
            json_inventory[group_name] = {"hosts": []}
            for hostname, host_vars in group_data.get("hosts", {}).items():
                json_inventory[group_name]["hosts"].append(hostname)
                if host_vars:
                    json_inventory["_meta"]["hostvars"][hostname] = host_vars
        print(json.dumps(json_inventory, indent=2))
        return

    if args.host:
        print(json.dumps({}))
        return

    # YAML output mode
    tf_output = get_terraform_output(args.terraform_dir)
    inventory = transform_to_yaml_inventory(tf_output)

    # Configure YAML dumper
    yaml.add_representer(type(None), yaml_representer_none)
    yaml_output = yaml.dump(
        inventory,
        default_flow_style=False,
        sort_keys=False,
        allow_unicode=True,
        indent=2
    )

    if args.output:
        output_path = Path(args.output)
        output_path.write_text(yaml_output)
        print(f"Inventory written to {output_path}", file=sys.stderr)
    else:
        print(yaml_output)


if __name__ == "__main__":
    main()
