variable "sns_topic_arn" {
  type = string
}

variable "step_function_arn" {
  type = string
}

variable "dlq_arns" {
  type = list(string)
}

variable "environment" {
  type = string
}

# DLQ alarm settings
variable "dlq_alarm_prefix" { type = string }
variable "dlq_comparison_operator" { type = string }
variable "dlq_evaluation_periods" { type = number }
variable "dlq_datapoints_to_alarm" { type = number }
variable "dlq_metric_name" { type = string }
variable "dlq_namespace" { type = string }
variable "dlq_period" { type = number }
variable "dlq_statistic" { type = string }
variable "dlq_threshold" { type = number }
variable "dlq_treat_missing_data" { type = string }
variable "dlq_alarm_description" { type = string }

# Step Function alarm settings
variable "step_function_alarm_prefix" { type = string }
variable "step_function_comparison_operator" { type = string }
variable "step_function_evaluation_periods" { type = number }
variable "step_function_metric_name" { type = string }
variable "step_function_namespace" { type = string }
variable "step_function_period" { type = number }
variable "step_function_statistic" { type = string }
variable "step_function_threshold" { type = number }
variable "step_function_alarm_description" { type = string }
