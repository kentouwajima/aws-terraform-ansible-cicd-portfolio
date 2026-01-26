# ----------------------------
# Application Load Balancer
# ----------------------------
resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# ----------------------------
# Target Group
# ----------------------------
resource "aws_lb_target_group" "this" {
  name     = "${var.project_name}-tg"
  port     = 8080 # Spring Bootのポート
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/" # アプリのルートパス
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# ----------------------------
# Listener
# ----------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80" # ユーザーアクセスのポート
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# ----------------------------
# Attachment
# ----------------------------
resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.ec2_instance_id
  port             = 8080 # EC2側のポート
}