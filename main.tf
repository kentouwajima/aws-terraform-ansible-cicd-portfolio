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