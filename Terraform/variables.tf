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
