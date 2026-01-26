# ----------------------------
# WAF Web ACL
# ----------------------------
resource "aws_wafv2_web_acl" "this" {
  name        = "${var.project_name}-web-acl"
  description = "Web ACL for ${var.project_name}"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # AWS Managed Rules (Common Rule Set)
  # 一般的な脅威（SQLインジェクション、XSSなど）をブロック
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf-metric"
    sampled_requests_enabled   = true
  }
}

# ----------------------------
# WAF Log Group
# ----------------------------
resource "aws_cloudwatch_log_group" "waf_logs" {
  # WAFのロググループ名は必ず "aws-waf-logs-" で始まる必要があります
  name              = "aws-waf-logs-${var.project_name}"
  retention_in_days = 7
}

# ----------------------------
# Logging Configuration
# ----------------------------
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.this.arn
}

# ----------------------------
# Association (ALBへの紐付け)
# ----------------------------
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}