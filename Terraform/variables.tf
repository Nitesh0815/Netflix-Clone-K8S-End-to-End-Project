variable "aws-region" {}
variable "env" {}
variable "cidr-block" {}
variable "pub-subnet-count" {}
variable "pub-cidr-block" {
  type = list(string)
}
variable "pub-availability-zone" {
  type = list(string)
}
variable "ec2-instance-count" {}
variable "ec2_instance_type" {
  type = list(string)
}
variable "ec2_volume_size" {}
variable "ec2_volume_type" {}

# NEW: Variable definition for the SSH Public Key
variable "ssh_public_key" {
  description = "The SSH public key material used for EC2 instance access."
  type        = string
}

variable "project" {
  description = "The name of the project for resource tagging and naming."
  type        = string
}
