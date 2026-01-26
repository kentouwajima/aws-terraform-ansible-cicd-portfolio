output "ec2_public_ip" {
  description = "EC2インスタンスへの接続用Public IP"
  value       = module.compute.public_ip
}

output "rds_endpoint" {
  value = module.database.db_endpoint
}

output "alb_dns_name" {
  description = "Web Application URL"
  value       = "http://${module.loadbalancer.alb_dns_name}"
}