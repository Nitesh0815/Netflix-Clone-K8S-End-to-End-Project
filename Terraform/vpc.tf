# -------------------------------
# VPC
# -------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-vpc"
    Env  = local.env
  }
}

# -------------------------------
# Internet Gateway
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-igw"
    Env  = local.env
  }

  depends_on = [aws_vpc.vpc]
}

# -------------------------------
# Public Subnets
# -------------------------------
resource "aws_subnet" "public_subnet" {
  count                   = var.pub_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.pub_cidr_block, count.index)
  availability_zone       = element(var.pub_availability_zone, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-public-subnet-${count.index + 1}"
    Env  = local.env
  }

  depends_on = [aws_vpc.vpc]
}

# -------------------------------
# Route Table
# -------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-public-route-table"
    Env  = local.env
  }

  depends_on = [aws_vpc.vpc]
}

# -------------------------------
# Route Table Associations
# -------------------------------
resource "aws_route_table_association" "public_rta" {
  count          = var.pub_subnet_count
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.public_subnet
  ]
}

# -------------------------------
# Default Security Group
# -------------------------------
resource "aws_security_group" "default_ec2_sg" {
  name        = "${local.org}-${local.project}-${local.env}-sg"
  description = "Default EC2 Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all inbound traffic (for demo)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-sg"
    Env  = local.env
  }
}
