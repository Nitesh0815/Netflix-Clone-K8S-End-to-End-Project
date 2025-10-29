locals {
  # 👇 Basic identifiers used for naming resources
  org     = "aman"
  project = "netflix-clone"
  env     = var.env

  # 👇 Consistent resource naming format across the project
  name_prefix = "${local.org}-${local.project}-${local.env}"

  # 👇 EC2 instance logical names (used for tagging)
  instance_names = [
    "jenkins-server",
    "monitoring-server",
    "kubernetes-master-node",
    "kubernetes-worker-node"
  ]
}