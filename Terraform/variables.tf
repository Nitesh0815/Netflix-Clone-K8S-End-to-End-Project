variable "aws-region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "env" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "cidr-block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "pub-subnet-count" {
  description = "Number of public subnets to create."
  type        = number
}

variable "pub-cidr-block" {
  description = "List of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "pub-availability-zone" {
  description = "List of Availability Zones for the public subnets."
  type        = list(string)
}

variable "ec2-instance-count" {
  description = "Number of EC2 instances to create."
  type        = number
}

variable "ec2_instance_type" {
  description = "List of instance types for EC2 instances."
  type        = list(string)
}

variable "ec2_volume_size" {
  description = "The size of the root volume in GB."
  type        = number
}

variable "ec2_volume_type" {
  description = "The type of the root volume (e.g., gp3)."
  type        = string
}

# NEW: Variable definition for the SSH Public Key
variable "ssh_public_key" {
  description = "The SSH public key material used for EC2 instance access."
  type        = string
}

variable "project" {
  description = "The name of the project for resource tagging and naming."
  type        = string
}
