output "instance_profile_name" {
  description = "Instance profile name to attach to EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "instance_profile_arn" {
  description = "Instance profile ARN"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "ec2_role_name" {
  description = "IAM role name"
  value       = aws_iam_role.ec2_role.name
}

