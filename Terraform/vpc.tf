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
}

# -------------------------------
# Route Table Associations
# -------------------------------
resource "aws_route_table_association" "public_rta" {
  count          = var.pub_subnet_count
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# -------------------------------
# 1. Security Group for Jenkins Server (Index 0)
# NOTE: SSH and UI open to 0.0.0.0/0 for convenience. 
#       Replace with your IP/VPN CIDR for production (e.g., "203.0.113.0/24")
# -------------------------------
resource "aws_security_group" "jenkins_sg" {
  name        = "${local.org}-${local.project}-${local.env}-jenkins-sg"
  description = "Security Group for Jenkins Server (SSH/8080)"
  vpc_id      = aws_vpc.vpc.id

  # Allow SSH from anywhere (REPLACE 0.0.0.0/0)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Allow Jenkins UI access (REPLACE 0.0.0.0/0)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------
# 2. Security Group for Monitoring Server (Index 1)
# -------------------------------
resource "aws_security_group" "monitoring_sg" {
  name        = "${local.org}-${local.project}-${local.env}-monitoring-sg"
  description = "Security Group for Monitoring (SSH/Prometheus/Grafana)"
  vpc_id      = aws_vpc.vpc.id

  # Allow SSH (REPLACE 0.0.0.0/0)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Grafana UI (REPLACE 0.0.0.0/0)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Prometheus UI (REPLACE 0.0.0.0/0)
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------
# 3. Security Group for Kubernetes Nodes (Index 2, 3)
# -------------------------------
resource "aws_security_group" "kubernetes_sg" {
  name        = "${local.org}-${local.project}-${local.env}-k8s-sg"
  description = "Security Group for Kubernetes Nodes (SSH/API/Kubelet)"
  vpc_id      = aws_vpc.vpc.id

  # Allow SSH (REPLACE 0.0.0.0/0)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow K8s API Server (Control Plane access) - RESTRICTED TO JENKINS SG
  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id] 
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}