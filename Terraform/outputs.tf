output "ec2_public_ips" {
  description = "Public IPs of all EC2 instances"
  value       = aws_instance.ec2[*].public_ip
}

output "vpc_id" {
  description = "ID of created VPC"
  value       = aws_vpc.vpc.id
}