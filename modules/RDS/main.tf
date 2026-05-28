# ─── DB SUBNET GROUP ────────────────────────────────────────

resource "aws_db_subnet_group" "main" {
  name        = "${var.environment}-db-subnet-group"
  description = "Subnet group for RDS"
  subnet_ids  = var.private_subnet_ids
  # hand both private subnets to RDS
  # RDS uses these for placement and Multi-AZ failover

  tags = {
    Name      = "${var.environment}-db-subnet-group"
    ManagedBy = "terraform"
  }
}

# ─── SECURITY GROUP — RDS ───────────────────────────────────

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from app server only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
    # port 3306 = MySQL port
    # only app server security group can connect
    # same pattern as app server only allowing bastion
    # nobody else — not bastion, not internet — can hit the DB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.environment}-rds-sg"
    ManagedBy = "terraform"
  }
}

# ─── RDS INSTANCE ───────────────────────────────────────────

resource "aws_db_instance" "main" {
  identifier        = "${var.environment}-database"
  # identifier = name of the RDS instance in AWS console

  engine         = "mysql"
  engine_version = "8.0"
  # which database engine and version
  # options: mysql, postgres, mariadb, oracle, sqlserver

  instance_class    = var.db_instance_class
  allocated_storage = var.allocated_storage
  # how powerful and how much disk space

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  # database credentials
  # password is marked sensitive so never printed

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  # which subnets and which firewall to use

  multi_az            = false
  # false for dev — saves money
  # true for prod — automatic standby in second AZ
  # when primary dies, standby takes over automatically

  publicly_accessible = false
  # NEVER make database publicly accessible
  # only reachable from inside VPC

  skip_final_snapshot = true
  # when you run terraform destroy
  # false = AWS takes a final backup before deleting (prod)
  # true  = just delete immediately (dev/test)

  backup_retention_period = 7
  # keep automatic backups for 7 days
  # if data gets corrupted you can restore to any point
  # in last 7 days

  tags = {
    Name      = "${var.environment}-database"
    ManagedBy = "terraform"
  }
}
