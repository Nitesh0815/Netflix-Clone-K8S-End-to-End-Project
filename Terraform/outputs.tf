resource "aws_key_pair" "deployer_key" {
  # Key name is constructed using locals defined in vpc.tf
  key_name = "${local.org}-${local.project}-${local.env}-key"
  # This variable must be passed from the GitHub Action secret SSH_PUBLIC_KEY
  public_key = var.ssh_public_key
}

output "public_ip_addresses" {
  description = "The public IP addresses of the created EC2 instances"
  value       = aws_instance.ec2.*.public_ip
}

output "instance_names" {
  description = "The names of the created EC2 instances"
  value       = aws_instance.ec2.*.tags.Name
}

output "ssh_key_name" {
  description = "The name of the SSH key pair created"
  value       = aws_key_pair.deployer_key.key_name
}
