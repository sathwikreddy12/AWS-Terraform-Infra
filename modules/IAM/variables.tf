variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "bucket_arn" {
  description = "S3 bucket ARN from S3 module"
  type        = string
  # IAM policy needs to know WHICH bucket to grant access to
  # comes from module.S3.bucket_arn
}

