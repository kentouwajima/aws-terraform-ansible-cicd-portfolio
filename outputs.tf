output "ec2_public_ip" {
  description = "EC2インスタンスへの接続用Public IP"
  value       = module.compute.public_ip
}