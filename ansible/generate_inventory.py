#!/usr/bin/env python3
import json
import yaml
import os
import subprocess

# ===============================================================
# Description:
#   Dynamically generate ansible/inventory.yml from Terraform outputs.
#   Works for setups with Jenkins, Monitoring, K8s Master, and Workers.
# ===============================================================

def get_terraform_output():
    """Run `terraform output -json` and return parsed JSON."""
    try:
        result = subprocess.run(
            ["terraform", "output", "-json"],
            cwd="../Terraform",  # Adjust path if Terraform dir is elsewhere
            check=True,
            capture_output=True,
            text=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print("❌ Error running terraform output command.")
        print(e.stderr)
        exit(1)
    except json.JSONDecodeError:
        print("❌ Failed to parse Terraform JSON output.")
        exit(1)


def generate_inventory(data):
    """Generate inventory structure based on Terraform outputs."""
    inventory = {
        "all": {
            "vars": {
                "ansible_user": "ubuntu",
                "ansible_connection": "ssh",
                "ansible_ssh_private_key_file": "~/.ssh/id_rsa"
            },
            "children": {
                "jenkins": {
                    "hosts": {
                        "jenkins_server": {
                            "ansible_host": data["jenkins_public_ip"]["value"]
                        }
                    }
                },
                "monitoring": {
                    "hosts": {
                        "monitoring_server": {
                            "ansible_host": data["monitoring_public_ip"]["value"]
                        }
                    }
                },
                "k8s_master": {
                    "hosts": {
                        "k8s_master_node": {
                            "ansible_host": data["k8s_master_public_ip"]["value"]
                        }
                    }
                },
                "k8s_worker": {
                    "hosts": {}
                }
            }
        }
    }

    # If there are multiple worker nodes, add them dynamically
    if "k8s_worker_public_ips" in data and isinstance(data["k8s_worker_public_ips"]["value"], list):
        for idx, ip in enumerate(data["k8s_worker_public_ips"]["value"], start=1):
            inventory["all"]["children"]["k8s_worker"]["hosts"][f"k8s_worker_node{idx}"] = {
                "ansible_host": ip
            }

    return inventory


def write_inventory_to_file(inventory, filename="inventory.yml"):
    """Write inventory dictionary to a YAML file."""
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, "w") as f:
        yaml.dump(inventory, f, default_flow_style=False)
    print(f"✅ Inventory file generated successfully → {filename}")


if __name__ == "__main__":
    print("📦 Generating Ansible inventory from Terraform outputs...")
    tf_data = get_terraform_output()
    ansible_inventory = generate_inventory(tf_data)
    write_inventory_to_file(ansible_inventory, "ansible/inventory.yml")
