# ----------------------------
# SNS Topic
# ----------------------------
resource "aws_sns_topic" "cpu_alarm" {
  name         = "${var.project_name}-cpu-alarm-topic"
  display_name = "${var.project_name} Alarm"
}

# ----------------------------
# SNS Subscription (Email)
# ----------------------------
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cpu_alarm.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ----------------------------
# CloudWatch Alarm (EC2 CPU)
# ----------------------------
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name        = "${var.project_name}-ec2-cpu-high"
  alarm_description = "Alarm when CPU exceeds 10%"
  namespace         = "AWS/EC2"
  metric_name       = "CPUUtilization"

  # 監視対象の特定 (変数から受け取る)
  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60 # 1分 (60秒)
  statistic           = "Average"
  threshold           = 10 # テストしやすいように低めに設定

  # アラーム状態になった時のアクション（SNSへの通知）
  alarm_actions = [aws_sns_topic.cpu_alarm.arn]
  ok_actions    = [aws_sns_topic.cpu_alarm.arn] # 正常に戻った時も通知（任意）
}

# ----------------------------
# CloudWatch Alarm (WAF Blocked)
# ----------------------------
resource "aws_cloudwatch_metric_alarm" "waf_blocked" {
  alarm_name        = "${var.project_name}-waf-blocked"
  alarm_description = "Alarm when WAF blocks any request"
  namespace         = "AWS/WAFV2"
  metric_name       = "BlockedRequests"

  # 監視対象の特定
  dimensions = {
    WebACL = var.waf_web_acl_name
    Region = "ap-northeast-1"
    Rule   = "ALL" # 全てのルールの合計を監視
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60 # 1分間隔でチェック
  statistic           = "Sum"
  threshold           = 0 # 1件でもブロックされたら通知

  treat_missing_data = "notBreaching"

  # アクション (既存のSNSトピックを使用)
  alarm_actions = [aws_sns_topic.cpu_alarm.arn]
}