variable "project_name" {
  description = "リソース名のプレフィックス（例: portfolio）"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC全体のCIDRブロック"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "パブリックサブネットのCIDRリスト"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "プライベートサブネットのCIDRリスト"
  type        = list(string)
}

variable "availability_zones" {
  description = "使用するアベイラビリティゾーンのリスト"
  type        = list(string)
}