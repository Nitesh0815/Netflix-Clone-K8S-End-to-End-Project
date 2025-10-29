import json
import sys

if len(sys.argv) != 3:
    print("Usage: python3 generate_inventory.py <terraform_output_json> <inventory_file>")
    sys.exit(1)

# Read Terraform JSON output
with open(sys.argv[1]) as f:
    data = json.load(f)

# Adjust if your Terraform output is wrapped inside 'ec2_public_ips'
if "ec2_public_ips" in data:
    ips = data["ec2_public_ips"]["value"]
else:
    ips = data["value"]

# Write Ansible inventory
with open(sys.argv[2], "w") as f:
    f.write(f"[jenkins]\n{ips[0]}\n\n")
    f.write(f"[monitoring]\n{ips[1]}\n\n")
    f.write(f"[kubernetes_master]\n{ips[2]}\n\n")
    f.write(f"[kubernetes_worker]\n{ips[3]}\n\n")
    f.write("[all:vars]\nansible_user=ubuntu\nansible_ssh_private_key_file=~/.ssh/id_rsa\n")
