terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket = "tf-state-aws-study-kentouwajima"
    # 重要: 既存の学習用Stateと混ざらないようパスを変更
    key    = "portfolio/terraform.tfstate"
    region = "ap-northeast-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# ---------------------------------------------
# Network Module の呼び出し
# ---------------------------------------------
module "network" {
  source = "./modules/network"

  # 左側が「モジュールのvariables.tf」、右側が「ルートのvariables.tf」
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# ---------------------------------------------
# Security Module
# ---------------------------------------------
module "security" {
  source = "./modules/security"

  project_name     = var.project_name
  vpc_id           = module.network.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

# ---------------------------------------------
# Compute Module
# ---------------------------------------------
module "compute" {
  source = "./modules/compute"

  project_name      = var.project_name
  public_subnet_id  = module.network.public_subnet_ids[0] # 1つ目のPublicサブネットを使用
  security_group_id = module.security.ec2_sg_id
  key_name          = var.key_name
}

# ---------------------------------------------
# Database Module
# ---------------------------------------------
module "database" {
  source = "./modules/database"

  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.security.rds_sg_id
  db_password        = var.db_password
}

# ---------------------------------------------
# LoadBalancer Module
# ---------------------------------------------
module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  security_group_id = module.security.alb_sg_id
  ec2_instance_id   = module.compute.instance_id
}

# ---------------------------------------------
# Monitoring Module
# ---------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  project_name     = var.project_name
  ec2_instance_id  = module.compute.instance_id # ComputeモジュールからIDをもらう
  alert_email      = var.alert_email
  waf_web_acl_name = module.waf.web_acl_name
}

# ---------------------------------------------
# WAF Module 
# ---------------------------------------------
module "waf" {
  source = "./modules/waf"

  project_name = var.project_name
  alb_arn      = module.loadbalancer.alb_arn
}