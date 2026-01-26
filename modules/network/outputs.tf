output "vpc_id" {
  description = "作成されたVPCのID"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPCのCIDR"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "パブリックサブネットIDのリスト"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "プライベートサブネットIDのリスト"
  value       = aws_subnet.private[*].id
}