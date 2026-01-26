variable "project_name" {
  type = string
}

variable "ec2_instance_id" {
  description = "監視対象のEC2インスタンスID"
  type        = string
}

variable "alert_email" {
  description = "アラート通知先のメールアドレス"
  type        = string
}