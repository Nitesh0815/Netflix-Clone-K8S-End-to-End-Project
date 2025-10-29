# EC2 Instance Resource
resource "aws_instance" "ec2" {
  count                  = var.ec2_instance_count
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = aws_subnet.public_subnet[count.index].id
  instance_type          = var.ec2_instance_type[count.index]
  key_name               = var.ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.iam_instance_profile.name
  
  # Dynamically assign security groups based on index/role
  vpc_security_group_ids = [
    element(
      [
        aws_security_group.jenkins_sg.id,       # Index 0: jenkins-server
        aws_security_group.monitoring_sg.id,    # Index 1: monitoring-server
        aws_security_group.kubernetes_sg.id,    # Index 2: kubernetes-master-node
        aws_security_group.kubernetes_sg.id,    # Index 3: kubernetes-worker-node
      ],
      count.index
    )
  ]

  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = var.ec2_volume_type
  }

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-${local.instance_names[count.index]}"
    Env  = local.env
    Role = split("-", local.instance_names[count.index])[0] # E.g., "jenkins", "monitoring", "kubernetes"
  }
}