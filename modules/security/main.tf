# ----------------------------
# Security Group for EC2
# ----------------------------
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2"
  vpc_id      = var.vpc_id

  # Inbound: SSH (特定のIPのみ許可)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
    description = "Allow SSH from My IP"
  }

  # Inbound: HTTP (動作確認用: 全開放)
  # ※将来ALB導入時にソースをALBのみに変更予定
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from Anywhere"
  }

  # Outbound: 全許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# ----------------------------
# Security Group for RDS
# ----------------------------
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  # Inbound: MySQL (EC2のSGからのみ許可)
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id] # 同ファイル内のEC2 SGを参照
    description     = "Allow MySQL from EC2"
  }

  # Outbound: 通常は不要だが、推奨設定として全許可を入れておく
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}