# environments/dev/variables.tf

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
}

variable "instance_type"{
  description = "EC2 instance type"
  type = string
}

variable "ami_id"{
  description = "AMI id for EC2 instance"
  type = string
}
variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage" {
  description = "RDS storage in GB"
  type        = number
}
variable "app_server_count" {
  description = "Number of app servers"
  type        = number
}
variable "app_port" {
  description = "Port the app server listens on"
  type        = number
}
variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}
variable "enable_versioning" {
  description = "Enable S3 versioning"
  type        = bool
}



