locals {
  instance_names = [
    "jenkins_server",
    "monitoring_server",
    "kubernetes_master_node",
    "kubernetes_worker_node"
  ]
}

resource "aws_instance" "ec2" {
  count                  = var.ec2-instance-count
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = aws_subnet.public_subnet[count.index].id
  instance_type          = var.ec2_instance_type[count.index]
  iam_instance_profile   = aws_iam_instance_profile.iam_instance_profile.name
  vpc_security_group_ids = [aws_security_group.default_ec2_sg.id]

  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = var.ec2_volume_type
  }

  # ✅ Ensure SSM Agent is running
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y snapd
              snap install amazon-ssm-agent --classic
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              EOF

  tags = {
    Name    = "${local.org}-${local.project}-${local.env}-${local.instance_names[count.index]}"
    Role    = local.instance_names[count.index]
    Env     = local.env
    Project = "Netflix"
  }

  depends_on = [aws_iam_instance_profile.iam_instance_profile]
}
