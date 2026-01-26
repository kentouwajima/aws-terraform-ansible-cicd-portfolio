variable "project_name" {
  description = "プロジェクト名"
  type        = string
  default     = "portfolio"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# デフォルト値を設定しておくことで、tfvarsに書かなくても動くようにしています
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "allowed_ssh_cidr" {
  description = "Allowed CIDR for SSH access"
  type        = string
}