# ─── KEY PAIR ───────────────────────────────────────────────

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.environment}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/${var.environment}-key.pem"
  file_permission = "0400"
}

# ─── SECURITY GROUP — BASTION ───────────────────────────────

resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.environment}-bastion-sg"
    ManagedBy = "terraform"
  }
}

# ─── SECURITY GROUP — APP SERVER ────────────────────────────

resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Security group for app server"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH only from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description = "App traffic from inside VPC only"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.environment}-app-sg"
    ManagedBy = "terraform"
  }
}

# ─── BASTION HOST ───────────────────────────────────────────

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.ec2_key.key_name
  associate_public_ip_address = true
  iam_instance_profile        = var.instance_profile_name

  tags = {
    Name      = "${var.environment}-bastion"
    ManagedBy = "terraform"
  }
}

# ─── APP SERVER ─────────────────────────────────────────────

resource "aws_instance" "app" {
  count = var.app_server_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = aws_key_pair.ec2_key.key_name
  associate_public_ip_address = false
  iam_instance_profile        = var.instance_profile_name

  tags = {
    Name      = "${var.environment}-app-server"
    ManagedBy = "terraform"
  }
}
