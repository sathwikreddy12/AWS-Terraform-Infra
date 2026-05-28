output "bastion_public_ip" {
  description = "Public IP to SSH into bastion"
  value       = aws_instance.bastion.public_ip
}

output "app_private_ips" {
  description = "Private IPs of all  app servers"
  value       = aws_instance.app[*].private_ip
}

output "bastion_sg_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.bastion.id
}

output "app_sg_id" {
  description = "App server security group ID"
  value       = aws_security_group.app.id
}

output "private_key_path" {
  description = "Path to the .pem file saved on this machine"
  value       = local_file.private_key.filename
}
output "app_instance_ids"{
  description = "Instance IDs of all the app servers"
  value       = aws_instance.app[*].id
}


