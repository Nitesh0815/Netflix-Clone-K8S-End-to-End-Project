resource "aws_iam_role" "ssm_iam_role" {
  name = "${local.org}-${local.project}-${local.env}-ssm-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-ssm-iam-role"
    Env  = local.env
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_attach" {
  role       = aws_iam_role.ssm_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${local.org}-${local.project}-${local.env}-instance-profile"
  role = aws_iam_role.ssm_iam_role.name
}