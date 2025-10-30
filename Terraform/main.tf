locals {
  instance_names = [
    "jenkins-server",
    "monitoring-server",
    "kubernetes-master-node",
    "kubernetes-worker-node"
  ]
}

resource "aws_instance" "ec2" {
  count                  = var.ec2-instance-count
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = aws_subnet.public-subnet[count.index].id
  instance_type          = var.ec2_instance_type[count.index]
  iam_instance_profile   = aws_iam_instance_profile.iam-instance-profile.name
  vpc_security_group_ids = [aws_security_group.default-ec2-sg.id]

  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = var.ec2_volume_type
  }

  # Ensure SSM agent present & running (cloud-init script)
  user_data = <<-EOF
              #!/bin/bash
              set -e
              # Update & install common packages
              apt-get update -y
              apt-get install -y ca-certificates curl
              # Install or restart amazon-ssm-agent (works for ubuntu)
              if command -v snap >/dev/null 2>&1; then
                # newer images may have snap-installed agent
                snap install amazon-ssm-agent || true
                systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service || true
              fi
              # Attempt apt install (idempotent)
              apt-get install -y amazon-ssm-agent || true
              systemctl enable --now amazon-ssm-agent || true
              EOF

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-${local.instance_names[count.index]}"
    Env  = "${local.env}"
  }
}
