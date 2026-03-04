#!/usr/bin/env python3
import os
import sys
import re
import json
import ssl
import urllib.request
import urllib.parse

def debug(msg):
    """Print debug message to stderr"""
    print(f"[DEBUG] {msg}", file=sys.stderr)

def get_tfvar(env, app, var_name):
    # List of files to check
    files_to_check = []

    if app:
        files_to_check.append(f"environments/{env}/{app}.tfvars")

    files_to_check.append(f"environments/{env}/{env}.tfvars")
    files_to_check.append("secrets.auto.tfvars")

    debug(f"Looking for '{var_name}' in files: {files_to_check}")

    for file_path in files_to_check:
        if not os.path.exists(file_path):
            debug(f"  File not found: {file_path}")
            continue

        debug(f"  Checking file: {file_path}")
        with open(file_path, 'r') as f:
            content = f.read()

        # Regex to find variable definition: var_name = "value"
        match = re.search(rf'{var_name}\s*=\s*"([^"]+)"', content)
        if match:
            debug(f"  Found '{var_name}' = '{match.group(1)}' in {file_path}")
            return match.group(1)

    debug(f"  Variable '{var_name}' not found in any file")
    return None

def main():
    env = "dev"
    app = None

    debug(f"Script started with args: {sys.argv}")
    debug(f"Current working directory: {os.getcwd()}")

    if len(sys.argv) >= 2:
        env = sys.argv[1]

    if len(sys.argv) >= 3:
        app = sys.argv[2]

    debug(f"Environment: {env}, App: {app}")

    # 1. Get Refresh Token from Env
    refresh_token = os.environ.get("VCD_REFRESH_TOKEN")
    if refresh_token:
        debug(f"VCD_REFRESH_TOKEN is set (length: {len(refresh_token)})")
    else:
        debug("VCD_REFRESH_TOKEN is NOT set")
        print("Error: VCD_REFRESH_TOKEN environment variable is not set.", file=sys.stderr)
        sys.exit(1)

    # 2. Get VCD URL and Org Name
    debug("Looking for VCD_URL...")
    vcd_url = os.environ.get("VCD_URL")
    if vcd_url:
        debug(f"VCD_URL from env: {vcd_url}")
    else:
        vcd_url = get_tfvar(env, app, "vcd_url")

    debug("Looking for org_name...")
    org_name = os.environ.get("VCD_ORG")
    if org_name:
        debug(f"VCD_ORG from env: {org_name}")
    else:
        org_name = get_tfvar(env, app, "org_name")

    if not vcd_url:
        print(f"Error: Could not determine VCD_URL for environment '{env}' (App: {app}).", file=sys.stderr)
        sys.exit(1)
        
    if not org_name:
        print(f"Error: Could not determine org_name for environment '{env}' (App: {app}).", file=sys.stderr)
        sys.exit(1)
    
    # Clean up URL
    vcd_url = vcd_url.replace("https://", "").replace("http://", "").rstrip('/')
    if vcd_url.endswith("/api"):
        vcd_url = vcd_url[:-4]
    
    # 3. Prepare Request (Tenant Endpoint)
    # URL: https://<vcd_url>/oauth/tenant/<org_name>/token
    token_url = f"https://{vcd_url}/oauth/tenant/{org_name}/token"
    debug(f"Token URL: {token_url}")

    headers = {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
    }
    debug(f"Request headers: {headers}")

    data = urllib.parse.urlencode({
        "grant_type": "refresh_token",
        "refresh_token": refresh_token
    }).encode('utf-8')
    debug(f"Request body (encoded): grant_type=refresh_token&refresh_token=<hidden>")

    # 4. Make Request (Ignoring SSL errors as per project config)
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    debug("SSL verification disabled")

    try:
        debug("Sending POST request...")
        req = urllib.request.Request(token_url, data=data, headers=headers, method="POST")
        with urllib.request.urlopen(req, context=ctx) as response:
            debug(f"Response status: {response.status}")
            debug(f"Response headers: {dict(response.headers)}")

            if response.status != 200:
                print(f"Error: HTTP {response.status}", file=sys.stderr)
                sys.exit(1)

            body = response.read().decode('utf-8')
            debug(f"Response body length: {len(body)} chars")

            json_data = json.loads(body)
            debug(f"Response keys: {list(json_data.keys())}")

            access_token = json_data.get("access_token")
            if not access_token:
                debug(f"Full response: {body}")
                print("Error: No access_token in response", file=sys.stderr)
                sys.exit(1)

            debug(f"Access token received (length: {len(access_token)})")
            print(access_token)

    except urllib.error.HTTPError as e:
        debug(f"HTTPError: {e.code} {e.reason}")
        debug(f"Response body: {e.read().decode('utf-8')}")
        print(f"Error retrieving token: HTTP {e.code} {e.reason}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        debug(f"Exception type: {type(e).__name__}")
        print(f"Error retrieving token: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
