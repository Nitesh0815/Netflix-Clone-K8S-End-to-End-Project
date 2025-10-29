import json
import sys

# Define the expected Terraform output keys and the corresponding Ansible group names
# This assumes the Terraform outputs are named 'jenkins_server_ip', etc.
IP_MAP = {
    "jenkins_server_ip": "jenkins",
    "monitoring_server_ip": "monitoring",
    "k8s_master_ip": "kubernetes_master"
}

def generate_inventory(infile, outfile):
    """Reads Terraform output JSON and generates an Ansible inventory file."""
    
    print(f"Attempting to read Terraform output from: {infile}", file=sys.stderr)

    try:
        with open(infile, 'r') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: Input file not found at {infile}. Was 'terraform output -json' run correctly?", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Could not decode JSON from {infile}. Check Terraform output format.", file=sys.stderr)
        sys.exit(1)

    inventory_content = []
    found_ips = False

    for tf_key, ansible_group in IP_MAP.items():
        # Get the IP data. It's usually nested under {"value": "IP"}
        ip_data = data.get(tf_key)
        
        if ip_data is None:
            print(f"Warning: Terraform output key '{tf_key}' not found in JSON. Skipping group '{ansible_group}'.", file=sys.stderr)
            continue

        # Extract the IP value from either {"value": "IP"} or if it's a bare string
        ip_value = ip_data.get("value") if isinstance(ip_data, dict) else ip_data

        if not ip_value:
            print(f"Warning: IP value for '{tf_key}' is empty or null. Skipping group '{ansible_group}'.", file=sys.stderr)
            continue

        # Add group header and host entry
        inventory_content.append(f"[{ansible_group}]")
        # Use ansible_user=ubuntu as requested by the user. 
        # We rely on the SSH agent (Setup SSH Agent step) for the key, so we remove the file path.
        inventory_content.append(f"{ip_value} ansible_user=ubuntu\n")
        found_ips = True

    if not found_ips:
        print("Error: Failed to extract any valid IP addresses for the inventory.", file=sys.stderr)
        sys.exit(1)

    # Add all vars, including StrictHostKeyChecking=no
    inventory_content.append("[all:vars]")
    inventory_content.append("ansible_ssh_common_args='-o StrictHostKeyChecking=no'")

    try:
        with open(outfile, "w") as f:
            f.write('\n'.join(inventory_content))
    except Exception as e:
        print(f"Error writing to output file {outfile}: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"Inventory file successfully written to {outfile}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        # The script is run from the shell with the two arguments
        print("Usage: python inventory_generator.py <input_json_file> <output_inventory_file>", file=sys.stderr)
        sys.exit(1)
    generate_inventory(sys.argv[1], sys.argv[2])
