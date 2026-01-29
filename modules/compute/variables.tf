variable "project_name" {
  type = string
}

variable "public_subnet_id" {
  description = "EC2を配置するPublic SubnetのID"
  type        = string
}

variable "security_group_id" {
  description = "EC2に割り当てるSecurity Group ID"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}