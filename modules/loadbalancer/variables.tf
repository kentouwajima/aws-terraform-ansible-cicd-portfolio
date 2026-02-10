variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  description = "ALB Security Group ID"
  type        = string
}

variable "ec2_instance_id" {
  description = "EC2 Instance ID for Target Group"
  type        = string
}

variable "certificate_arn" {
  type    = string
  default = null # 最初は空でも動くようにしておくと安全です
}