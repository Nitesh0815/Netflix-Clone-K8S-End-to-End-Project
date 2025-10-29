variable "aws_region" {}
variable "env" {}
variable "cidr_block" {}
variable "pub_subnet_count" {}
variable "pub_cidr_block" {
  type = list(string)
}
variable "pub_availability_zone" {
  type = list(string)
}
variable "ec2_instance_count" {}
variable "ec2_instance_type" {
  type = list(string)
}
variable "ec2_volume_size" {}
variable "ec2_volume_type" {}

# New variable required for Ansible connectivity via GitHub Actions secret
variable "ssh_key_name" {
  description = "The name of the AWS Key Pair to use for SSH access to EC2 instances. Value is typically passed via the TF_VAR_ssh_key_name environment variable from GitHub Actions."
  type        = string
}