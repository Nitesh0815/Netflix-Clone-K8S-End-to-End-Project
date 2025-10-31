# ======================================
# IAM Role for EC2 (SSM Access Enabled)
# ======================================

resource "aws_iam_role" "ssm_role" {
  name = "${local.org}-${local.project}-${local.env}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-ssm-role"
    Env  = local.env
  }
}

# =================================================
# Attach AmazonSSMManagedInstanceCore Policy
# (Grants EC2 instance access to SSM)
# =================================================
resource "aws_iam_role_policy_attachment" "ssm_core_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# =================================================
# Optional but Recommended:
# Attach CloudWatchAgentServerPolicy
# (Allows EC2 instance to send logs/metrics)
# =================================================
resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ======================================
# Create IAM Instance Profile
# ======================================
resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${local.org}-${local.project}-${local.env}-instance-profile"
  role = aws_iam_role.ssm_role.name
}
