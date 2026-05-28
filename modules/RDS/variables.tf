variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from vpc module"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from vpc module"
  type        = list(string)
  # RDS always goes in private subnets
  # database should never be publicly accessible
}

variable "app_sg_id" {
  description = "App server security group ID from ec2 module"
  type        = string
  # only app server is allowed to talk to database
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
  # sensitive = true means terraform will never
  # print this value in plan or apply output
  # protects passwords from appearing in logs
}

variable "db_instance_class" {
  description = "RDS instance size"
  type        = string
  default     = "db.t3.micro"
  # db.t3.micro = free tier eligible
  # db.t3.medium = paid, more RAM
}

variable "allocated_storage" {
  description = "Storage size in GB"
  type        = number
  default     = 20
  # minimum is 20GB for MySQL
}
