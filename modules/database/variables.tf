variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "RDSを配置するプライベートサブネットIDのリスト"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "RDSに割り当てるセキュリティグループID"
  type        = string
}

variable "db_password" {
  description = "DBのマスターパスワード"
  type        = string
  sensitive   = true
}