import json
import sys
from collections import defaultdict

# --- Configuration ---
# EC2 instance index mapping to Ansible group names
# This must match the index order defined in your Terraform main.tf file:
# 0: jenkins-server
# 1: monitoring-server
# 2: kubernetes-master-node
# 3: kubernetes-worker-node
GROUP_MAP = [
    "jenkins_server",
    "monitoring_server",
    "kubernetes_master",
    "kubernetes_workers",
]

def generate_inventory(input_file, output_file):
    """
    Reads the JSON output of Terraform containing EC2 IPs and generates an
    Ansible inventory file (INI format).
    """
    try:
        with open(input_file, 'r') as f:
            # Terraform output structure: {"ec2_public_ips": {"value": ["ip0", "ip1", ...]}}
            tf_output = json.load(f)
            # Access the array of IPs
            ip_list = tf_output.get("ec2_public_ips", {}).get("value", [])

    except FileNotFoundError:
        print(f"Error: Input file not found: {input_file}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Failed to decode JSON from {input_file}. Check Terraform output format.", file=sys.stderr)
        sys.exit(1)

    if not ip_list:
        print("Error: IP list is empty in Terraform output. Ensure 'ec2_public_ips' is correct.", file=sys.stderr)
        sys.exit(1)

    # Dictionary to hold groups -> IP lists
    inventory = defaultdict(list)

    if len(ip_list) != len(GROUP_MAP):
        print(f"Warning: IP count ({len(ip_list)}) does not match expected groups ({len(GROUP_MAP)}). Group mapping may be incorrect.", file=sys.stderr)

    # Assign IPs to groups based on their index
    for i, ip in enumerate(ip_list):
        if i < len(GROUP_MAP):
            group_name = GROUP_MAP[i]
            inventory[group_name].append(ip)
        else:
            # Handle extra IPs gracefully if the count mismatch warning was ignored
            inventory['extra_hosts'].append(ip)

    # Generate INI format content
    inventory_content = ""
    # Define connection settings (assuming 'ubuntu' user and SSH key auth)
    inventory_content += "[all:vars]\n"
    inventory_content += "ansible_user=ubuntu\n"
    # Ensure raw module is used for systems where python is not initially configured (common in k8s)
    inventory_content += "ansible_python_interpreter=/usr/bin/python3\n\n"

    for group, ips in inventory.items():
        if ips:
            inventory_content += f"[{group}]\n"
            for ip in ips:
                inventory_content += f"{group}{ips.index(ip) + 1} ansible_host={ip}\n"
            inventory_content += "\n"

    try:
        with open(output_file, 'w') as f:
            f.write(inventory_content)
        print(f"Successfully generated Ansible inventory to {output_file}")
    except IOError:
        print(f"Error: Could not write to output file {output_file}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: python3 {sys.argv[0]} <terraform_output_json_file> <output_inventory_file>", file=sys.stderr)
        sys.exit(1)

    input_json_file = sys.argv[1]
    output_ini_file = sys.argv[2]
    generate_inventory(input_json_file, output_ini_file)
