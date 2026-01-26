variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "allowed_ssh_cidr" {
  description = "SSH接続を許可するIPアドレス (CIDR形式)"
  type        = string
}