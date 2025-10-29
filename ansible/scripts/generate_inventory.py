import json
import sys

# Define the expected index within the 'ec2_public_ips.value' array 
# and the corresponding Ansible group names.
IP_INDEX_MAP = {
    0: "jenkins",           # Maps aws_instance.ec2[0] IP
    1: "monitoring",        # Maps aws_instance.ec2[1] IP
    2: "kubernetes_master", # Maps aws_instance.ec2[2] IP
    # Index 3 IP (54.163.38.245) is currently ignored as it has no group defined, 
    # but you can add it here if needed (e.g., 3: "kubernetes_worker").
}

def generate_inventory(infile, outfile):
    """Reads Terraform output JSON (assuming 'ec2_public_ips' array) and generates an Ansible inventory file."""
    
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

    # CRITICAL: Access the single key 'ec2_public_ips' and its 'value' array
    ips_data = data.get("ec2_public_ips")
    if not ips_data or not isinstance(ips_data, dict) or "value" not in ips_data:
        print("Error: Could not find 'ec2_public_ips.value' array in Terraform JSON output.", file=sys.stderr)
        print(f"Received JSON keys: {list(data.keys())}", file=sys.stderr)
        sys.exit(1)
        
    all_ips = ips_data["value"]
    inventory_content = []
    found_ips = False

    # Iterate through the expected indices and assign IPs to groups
    for index, ansible_group in IP_INDEX_MAP.items():
        if index < len(all_ips):
            ip_value = all_ips[index]

            if not ip_value:
                print(f"Warning: IP value at index {index} is empty or null. Skipping group '{ansible_group}'.", file=sys.stderr)
                continue

            # Add group header and host entry
            inventory_content.append(f"[{ansible_group}]")
            # Use ansible_user=ubuntu as requested by the user. 
            # We rely on the SSH agent (Setup SSH Agent step) for the key.
            inventory_content.append(f"{ip_value} ansible_user=ubuntu\n")
            found_ips = True
        else:
            print(f"Warning: Index {index} (for {ansible_group}) is outside the bounds of the IP array (length {len(all_ips)}). Skipping.", file=sys.stderr)

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
