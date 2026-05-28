variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from vpc module"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs from vpc module"
  type        = list(string)
}

variable "app_instance_ids" {
  description = "List of app server instance IDs"
  type        = list(string)
  # accepts ALL app server IDs
  # ALB registers every single one in target group
}

variable "app_port" {
  description = "Port the app server listens on"
  type        = number
  default     = 8080
}
