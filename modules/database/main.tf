# ----------------------------
# RDS Subnet Group
# ----------------------------
resource "aws_db_subnet_group" "this" {
  name        = "${var.project_name}-rds-subnet-group"
  description = "RDS subnet group for ${var.project_name}"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

# ----------------------------
# RDS Instance
# ----------------------------
resource "aws_db_instance" "this" {
  identifier     = "${var.project_name}-rds"
  engine         = "mysql"
  engine_version = "8.0.43"
  instance_class = "db.t4g.micro" # 既存指定通り。t3.micro等が無料枠対象の場合もあり
  db_name        = "awsstudy"     # DB名はハイフン不可のため固定文字または変数化

  username = "admin" # rootよりadminが一般的（任意）
  password = var.db_password

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"

  # ネットワーク設定
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]
  multi_az               = false
  publicly_accessible    = false
  port                   = 3306

  # バックアップ・メンテ設定
  backup_retention_period    = 7
  auto_minor_version_upgrade = true

  # 削除時の設定（学習用: 削除保護なし、スナップショットなし）
  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately   = true

  tags = {
    Name = "${var.project_name}-rds"
  }
}