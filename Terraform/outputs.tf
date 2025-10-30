output "instance_public_ips" {
  description = "Public IPs of the created EC2 instances in order"
  value       = aws_instance.ec2[*].public_ip
}

output "instance_private_ips" {
  description = "Private IPs of the created EC2 instances in order"
  value       = aws_instance.ec2[*].private_ip
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.ec2[*].id
}
