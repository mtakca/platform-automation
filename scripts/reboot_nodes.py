
import os
import sys
import ssl
import urllib.request
import xml.etree.ElementTree as ET

def debug(msg):
    print(f"[DEBUG] {msg}", file=sys.stderr)

def main():
    if len(sys.argv) < 3:
        print("Usage: reboot_nodes.py <vcd_url> <vapp_name_or_id> <vm_name_pattern>")
        sys.exit(1)

    vcd_url = sys.argv[1]
    vapp_name = sys.argv[2] # e.g. "34-p5-sharedservice"
    vm_pattern = sys.argv[3] # e.g. "kafka"

    token = os.environ.get("VCD_ACCESS_TOKEN")
    if not token:
        print("Error: VCD_ACCESS_TOKEN needed.")
        sys.exit(1)

    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    # 1. Search for vApp by Name to get ID/HREF
    # Query API: /api/query?type=vApp&format=records&filter=name==vAppName
    query_url = f"https://{vcd_url}/query?type=vApp&format=records&filter=name=={vapp_name}"
    headers = {
        "Accept": "application/*+xml;version=37.0",
        "Authorization": f"Bearer {token}"
    }

    vapp_href = None
    try:
        req = urllib.request.Request(query_url, headers=headers)
        with urllib.request.urlopen(req, context=ctx) as response:
            xml_data = response.read().decode('utf-8')
            root = ET.fromstring(xml_data)
            # Namespace for query records
            # Usually http://www.vmware.com/vcloud/v1.5
            ns = {'vcloud': 'http://www.vmware.com/vcloud/v1.5'}
            for record in root.findall(".//vcloud:VAppRecord", ns):
                if record.get("name") == vapp_name:
                    vapp_href = record.get("href")
                    break
    except Exception as e:
        print(f"Error querying vApp: {e}")
        sys.exit(1)

    if not vapp_href:
        print(f"Error: vApp '{vapp_name}' not found.")
        sys.exit(1)

    debug(f"Found vApp HREF: {vapp_href}")

    # 2. Get vApp Details (Children VMs)
    try:
        req = urllib.request.Request(vapp_href, headers=headers)
        with urllib.request.urlopen(req, context=ctx) as response:
            xml_data = response.read().decode('utf-8')
            root = ET.fromstring(xml_data)
            ns = {'vcloud': 'http://www.vmware.com/vcloud/v1.5'}
            
            for child in root.findall(".//vcloud:Vm", ns):
                name = child.get("name")
                href = child.get("href")
                
                if vm_pattern in name:
                    debug(f"Matches pattern '{vm_pattern}': {name}")
                    # Reboot it
                    # Try reset first
                    action_url = f"{href}/power/action/reset"
                    debug(f"Sending RESET to {name}...")
                    
                    try:
                        req_reset = urllib.request.Request(action_url, headers=headers, method="POST")
                        with urllib.request.urlopen(req_reset, context=ctx) as resp:
                            print(f"Rebooted {name} (Status: {resp.status})")
                    except Exception as e:
                        print(f"Failed to reboot {name}: {e}")

    except Exception as e:
        print(f"Error getting vApp details: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
