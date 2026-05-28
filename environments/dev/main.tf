# environments/dev/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "../../modules/vpc"      # pointing to our module

  # values come from terraform.tfvars via variables.tf
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "ec2" {
  source = "../../modules/ec2"

  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  app_server_count   = var.app_server_count
  instance_profile_name = module.IAM.instance_profile_name
}

module "RDS"  {
  source = "../../modules/RDS"

  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  app_sg_id           = module.ec2.app_sg_id

  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  db_instance_class   = var.db_instance_class
  allocated_storage   = var.allocated_storage
}

module "ALB" {
  source = "../../modules/ALB"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  app_instance_ids  = module.ec2.app_instance_ids
  app_port          = var.app_port
}

module "S3" {
  source = "../../modules/s3"
  
  environment        = var.environment
  bucket_name        = var.bucket_name
  enable_versioning  = var.enable_versioning
}

module "IAM" {
  source = "../../modules/IAM"

  environment = var.environment
  bucket_arn  = module.S3.bucket_arn
}

# using the module's outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "bastion_public_ip" {
  value = module.ec2.bastion_public_ip
}

output "private_key_path" {
  value = module.ec2.private_key_path
}

output "db_endpoint" {
  value = module.RDS.db_endpoint
}
output "alb_dns_name" {
  value = module.ALB.alb_dns_name
}
output "app_private_ips" {
  value = module.ec2.app_private_ips
}

output "bucket_name" {
  value = module.S3.bucket_name
}

output "bucket_arn" {
  value = module.S3.bucket_arn
}
output "instance_profile_name" {
  value = module.IAM.instance_profile_name
}

output "ec2_role_name" {
  value = module.IAM.ec2_role_name
}







