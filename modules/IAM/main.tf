# ─── IAM ROLE ───────────────────────────────────────────────

resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  # Service = "ec2.amazonaws.com" means only EC2 instances
  # sts:AssumeRole = the action of putting on the role

  tags = {
    Name      = "${var.environment}-ec2-role"
    ManagedBy = "terraform"
  }
}

# ─── IAM POLICY ─────────────────────────────────────────────

resource "aws_iam_policy" "s3_access" {
  name        = "${var.environment}-s3-access-policy"
  description = "Allows EC2 to read and write to app S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",     # read files from bucket
          "s3:PutObject",     # upload files to bucket
          "s3:DeleteObject",  # delete files from bucket
          "s3:ListBucket"     # list files in bucket
        ]
        Resource = [
          var.bucket_arn,        # the bucket itself
          "${var.bucket_arn}/*"  # all objects inside bucket
        ]
        # bucket_arn     = arn:aws:s3:::dev-myapp-1809
        # bucket_arn/*   = arn:aws:s3:::dev-myapp-1809/*
        # some actions need bucket ARN
        # some need object ARN (bucket/*)
      }
    ]
  })
}

# ─── ATTACH POLICY TO ROLE ──────────────────────────────────

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access.arn
  # connects the policy to the role
  # without this the role exists but has no permissions
  # like a badge with no access level written on it
}

# ─── INSTANCE PROFILE ───────────────────────────────────────

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
  # wraps the role so EC2 can use it
  # EC2 cannot directly use a role
  # it needs an instance profile as a container
}
