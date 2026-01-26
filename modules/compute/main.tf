# ----------------------------
# AMI Data Source (SSM Parameter Store)
# ----------------------------
# 最新のAmazon Linux 2023 AMIを取得
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# ----------------------------
# Key Pair Generation
# ----------------------------
# 秘密鍵の生成
resource "tls_private_key" "keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 秘密鍵をローカルの指定パス (~/AWS/) に保存
# ※実行環境に ~/AWS ディレクトリが存在する必要があります
resource "local_file" "private_key_pem" {
  filename        = pathexpand("~/AWS/${var.project_name}-keypair.pem")
  content         = tls_private_key.keygen.private_key_pem
  file_permission = "0600"
}

# 公開鍵をAWSに登録
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.project_name}-keypair"
  public_key = tls_private_key.keygen.public_key_openssh
}

# ----------------------------
# EC2 Instance
# ----------------------------
resource "aws_instance" "app_server" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id

  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [var.security_group_id]

  # Public SubnetなのでIPを付与
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-ec2"
  }
}