output "db_endpoint" {
  description = "RDSのエンドポイント"
  value       = aws_db_instance.this.endpoint
}