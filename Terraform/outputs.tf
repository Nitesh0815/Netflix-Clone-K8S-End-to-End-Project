# ================================
# Output: EC2 Instance Information
# ================================

# Output the public IPs of all EC2 instances
output "ec2_public_ips" {
  description = "Public IPs of all EC2 instances"
  value       = [for instance in aws_instance.ec2 : instance.public_ip]
}

# Output the private IPs of all EC2 instances
output "ec2_private_ips" {
  description = "Private IPs of all EC2 instances"
  value       = [for instance in aws_instance.ec2 : instance.private_ip]
}

# Output the instance IDs for SSM connection
output "ec2_instance_ids" {
  description = "Instance IDs of all EC2 instances (for SSM)"
  value       = [for instance in aws_instance.ec2 : instance.id]
}

# Optional: Generate ready-to-use AWS CLI SSM connect commands
output "ssm_connect_commands" {
  description = "Run this command to connect to an instance via SSM"
  value = [
    for instance in aws_instance.ec2 :
    "aws ssm start-session --target ${instance.id}"
  ]
}
