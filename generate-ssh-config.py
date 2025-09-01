#!/usr/bin/env python3
import requests
import json
import sys
import os
from pathlib import Path
from datetime import datetime

def get_api_key():
    """Get API key from environment variable or Vast.AI config file"""
    # First check environment variable
    api_key = os.environ.get('VAST_API_KEY')
    if api_key:
        return api_key
    
    # Fall back to config file
    api_key_path = Path.home() / '.config' / 'vastai' / 'vast_api_key'
    
    try:
        with open(api_key_path, 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        print(f"Error: API key not found in environment variable VAST_API_KEY or at {api_key_path}", file=sys.stderr)
        print("Please set VAST_API_KEY environment variable or login to Vast.AI CLI", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error reading API key: {e}", file=sys.stderr)
        sys.exit(1)

def fetch_instances(api_token):
    """Fetch instances from Vast.AI API"""
    url = "https://console.vast.ai/api/v0/instances/"
    
    headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {api_token}'
    }
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching instances: {e}", file=sys.stderr)
        sys.exit(1)

def generate_ssh_config(instances):
    """Generate SSH config entries for Vast.AI instances"""
    config_entries = []
    
    for instance in instances.get('instances', []):
        # Extract SSH connection details from instance data
        instance_id = instance.get('id')
        public_ip = instance.get('public_ipaddr')
        
        # Check for direct SSH port mapping
        ssh_host = None
        ssh_port = None
        
        # First check if there's a direct SSH port mapping
        ports = instance.get('ports', {})
        if '22/tcp' in ports and ports['22/tcp']:
            # Use direct connection
            ssh_host = public_ip
            ssh_port = int(ports['22/tcp'][0]['HostPort'])
        elif instance.get('ssh_host') and instance.get('ssh_port'):
            # Fall back to proxy connection if no direct port
            ssh_host = instance.get('ssh_host')
            ssh_port = instance.get('ssh_port')
        
        # Skip if no SSH access available
        if not ssh_host or not ssh_port:
            continue
        
        # Extract GPU name and creation date
        gpu_name = instance.get('gpu_name', 'Unknown-GPU')
        # Clean up GPU name for use in hostname
        gpu_name = gpu_name.replace(' ', '-').replace('/', '-')

        # Convert start_date timestamp to readable format
        start_date = instance.get('start_date', 0)
        if start_date:
            dt = datetime.fromtimestamp(start_date)
            date_str = dt.strftime('%Y%m%d_%H%M%S')
        else:
            date_str = 'unknown_date'
        
        # Create host alias: GPU (date time instance_id)
        host_alias = f"{gpu_name}-{date_str}-{instance_id}"
        
        # Extract tags if available
        tags = instance.get('tag', [])
        if isinstance(tags, str):
            tags = [tags]
        
        # Determine connection type
        connection_type = "direct" if ssh_host == public_ip else "proxy"
        
        # Build config entry
        config_lines = []
        config_lines.append(f"# Connection: {connection_type}")
        if tags:
            config_lines.append(f"# Tags: {', '.join(tags)}")
        
        config_lines.append(f"Host {host_alias}")
        config_lines.append(f"    HostName {ssh_host}")
        config_lines.append(f"    Port {ssh_port}")
        config_lines.append("    User root")
        config_lines.append("    StrictHostKeyChecking no")
        config_lines.append("    UserKnownHostsFile /dev/null")
        
        config_entries.append('\n'.join(config_lines))
    
    return '\n\n'.join(config_entries)

def main():
    # Get API token from environment or config file
    api_token = get_api_key()
    
    # Fetch instances
    instances = fetch_instances(api_token)
    
    # Generate SSH config
    ssh_config = generate_ssh_config(instances)
    
    if not ssh_config:
        print("# No instances found or no SSH connection details available", file=sys.stderr)
        sys.exit(0)
    
    # Print SSH config to stdout
    print(ssh_config)

if __name__ == "__main__":
    main()
