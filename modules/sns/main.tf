terraform {
  backend "s3" {}
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
}

# Optional email subscription (we'll integrate SES later)
resource "aws_sns_topic_subscription" "email" {
  count = var.email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email
}

output "topic_arn" {
  value = aws_sns_topic.alerts.arn
}
