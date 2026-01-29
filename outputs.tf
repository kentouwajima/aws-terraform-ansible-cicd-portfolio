output "ec2_public_ip" {
  description = "EC2インスタンスへの接続用Public IP"
  value       = module.compute.public_ip
}

output "ec2_ssh_sg_id" {
  description = "Security Group ID for SSH access"
  value       = module.security.ec2_sg_id
}

output "rds_endpoint" {
  value = module.database.db_endpoint
}

output "alb_dns_name" {
  description = "Web Application URL"
  value       = "http://${module.loadbalancer.alb_dns_name}"
}