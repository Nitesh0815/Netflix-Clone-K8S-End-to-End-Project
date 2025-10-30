# 1. AWS KEY PAIR RESOURCE
# This creates the key pair in AWS using the public key passed via GitHub secrets.
resource "aws_key_pair" "deployer_key" {
  # Key name is constructed using locals defined in vpc.tf
  key_name   = "${local.org}-${local.project}-${local.env}-key"
  # This variable must be passed from the GitHub Action secret SSH_PUBLIC_KEY
  public_key = var.ssh_public_key
}

# 2. OUTPUT INSTANCE PUBLIC IPS
# This output is crucial. The GitHub Actions workflow (Ansible job) will
# read this JSON list to dynamically generate the inventory file.
output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances for Ansible connectivity."
  value       = aws_instance.ec2[*].public_ip
}