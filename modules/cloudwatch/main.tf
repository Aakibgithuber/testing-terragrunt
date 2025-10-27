terraform {
  backend "s3" {}
}

# DLQ alarms
resource "aws_cloudwatch_metric_alarm" "dlq_alarms" {
  for_each = toset(var.dlq_arns)

  alarm_name          = "${var.dlq_alarm_prefix}-${replace(each.value, ":", "-")}"
  comparison_operator = var.dlq_comparison_operator
  evaluation_periods  = var.dlq_evaluation_periods
  datapoints_to_alarm = var.dlq_datapoints_to_alarm
  metric_name         = var.dlq_metric_name
  namespace           = var.dlq_namespace
  period              = var.dlq_period
  statistic           = var.dlq_statistic
  threshold           = var.dlq_threshold
  treat_missing_data  = var.dlq_treat_missing_data
  alarm_description   = var.dlq_alarm_description
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    QueueName = regex("([^:]+)$", each.value)[0]
  }
}

# Step Function failure alarms
resource "aws_cloudwatch_metric_alarm" "step_function_failures" {
  alarm_name          = "${var.step_function_alarm_prefix}-${var.environment}"
  comparison_operator = var.step_function_comparison_operator
  evaluation_periods  = var.step_function_evaluation_periods
  metric_name         = var.step_function_metric_name
  namespace           = var.step_function_namespace
  period              = var.step_function_period
  statistic           = var.step_function_statistic
  threshold           = var.step_function_threshold
  alarm_description   = var.step_function_alarm_description
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    StateMachineArn = var.step_function_arn
  }
}
