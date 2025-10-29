import json, sys

infile, outfile = sys.argv[1], sys.argv[2]
data = json.load(open(infile))

# Works for either a dict with "value" or a plain list
if isinstance(data, dict) and "value" in data:
    ips = data["value"]
elif isinstance(data, list):
    ips = data
else:
    print("Unexpected JSON format:", type(data), data)
    sys.exit(1)

with open(outfile, "w") as f:
    f.write("[web]\n")
    for ip in ips:
        f.write(f"{ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa\n")

print(f"Inventory file written to {outfile}")
