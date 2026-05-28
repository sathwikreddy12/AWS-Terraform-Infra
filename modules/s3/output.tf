output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
  # IAM module will need this ARN
  # to give EC2 permission to access this bucket
}

output "bucket_domain_name" {
  description = "Domain name of the bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
  # full URL to access bucket
  # example: dev-myapp-assets.s3.amazonaws.com
}
