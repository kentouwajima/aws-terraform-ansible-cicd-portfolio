terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket = "tf-state-aws-study-kentouwajima"
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
# 1. Network Module
# ---------------------------------------------
module "network" {
  source = "./modules/network"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# ---------------------------------------------
# 2. Security Module
# ---------------------------------------------
module "security" {
  source = "./modules/security"

  project_name     = var.project_name
  vpc_id           = module.network.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

# ---------------------------------------------
# 3. Compute Module
# ---------------------------------------------
module "compute" {
  source = "./modules/compute"

  project_name      = var.project_name
  public_subnet_id  = module.network.public_subnet_ids[0]
  security_group_id = module.security.ec2_sg_id
  key_name          = var.key_name
}

# ---------------------------------------------
# 4. Database Module
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
# 5. DNS Module (最優先で作成)
# ---------------------------------------------
module "dns" {
  source = "./modules/dns"

  project_name = var.project_name
  domain_name  = "developers-lab.work"

  # 【重要】循環参照回避のため、初回はALBから直接参照せず固定値を指定するか
  # ALBモジュールができあがるのを待たずに定義できる値を渡します
  alb_dns_name = module.loadbalancer.alb_dns_name
  alb_zone_id  = module.loadbalancer.alb_zone_id
}

# ---------------------------------------------
# 6. LoadBalancer Module
# ---------------------------------------------
module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  security_group_id = module.security.alb_sg_id
  ec2_instance_id   = module.compute.instance_id

  # 【重要】初回Apply時はここをコメントアウトしてPushしてください
  # 一度Applyが成功し、ACM証明書が「発行済み」になればコメントを外せます
  # certificate_arn = module.dns.certificate_arn
}

# ---------------------------------------------
# 7. WAF Module 
# ---------------------------------------------
module "waf" {
  source = "./modules/waf"

  project_name = var.project_name
  alb_arn      = module.loadbalancer.alb_arn
}

# ---------------------------------------------
# 8. Monitoring Module
# ---------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  project_name     = var.project_name
  ec2_instance_id  = module.compute.instance_id
  alert_email      = var.alert_email
  waf_web_acl_name = module.waf.web_acl_name
}