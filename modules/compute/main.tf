# ----------------------------
# AMI Data Source (SSM Parameter Store)
# ----------------------------
# 最新のAmazon Linux 2023 AMIを取得
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# ----------------------------
# EC2 Instance
# ----------------------------
resource "aws_instance" "app_server" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id

  # ▼▼▼ 変更: 自動生成されたリソースではなく、変数を使用 ▼▼▼
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  # Public SubnetなのでIPを付与
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-ec2"
  }
}