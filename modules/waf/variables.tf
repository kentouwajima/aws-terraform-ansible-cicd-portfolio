variable "project_name" {
  type = string
}

variable "alb_arn" {
  description = "WAFを適用するALBのARN"
  type        = string
}