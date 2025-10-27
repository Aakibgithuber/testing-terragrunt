variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

# 🔹 DLQ ARN for Lambda
variable "dead_letter_target_arn" {
  description = "ARN of the SQS DLQ to send failed events"
  type        = string
  default     = null
}

variable "handler" {
  description = "Handler name"
  type        = string
}

variable "runtime" {
  description = "lambda runtime"
  type        = string
}

variable "timeout" {
  description = "lambda timeout"
  type        = number
}

variable "memory_size" {
  description = "lambda memory size"
  type        = number
}

variable "directory" {
  description = "lamda handler code directory"
  type        = string
}
variable "region" {
  description = "Name of the AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "app_name" {
  description = "application nam (e.g navirego)"
  type        = string
  default     = "navirego"
}

variable "sftp_teams_webhook_url" {
  description = "MS teams webhook url"
  type        = string
  default     = "https://viveknarainnavirego.webhook.office.com/webhookb2/07e9cba0-6566-46a0-92a4-005ce38e23f1@5eceead2-8a26-4d4e-88d7-38045b30916d/IncomingWebhook/0479ee44f32b44728a2dbf381d88a742/06c010ea-8be4-4ea0-8c76-2de7b11e1684/V24yzYa7HK-EbrIqsI7w-ZVrI1_uOm3DSc_-FA0VZJiSc1"
}

variable "sftp_host" {
  description = "sftp host"
  type        = string
  default     = "file.aegroup.biz"
}
variable "sftp_port" {
  description = "sftp port"
  type        = number
  default     = 22
}
variable "sftp_sql_dir" {
  description = "directory for backup files"
  type        = string
  default     = "/SQL DB"
}
variable "sftp_concurrency" {
  description = "sftp concurrency"
  type        = number
  default     = 50
}
variable "sftp_pool_size" {
  description = "sftp pool size"
  type        = number
  default     = 4
}

variable "lambda_layers" {
  description = "List of Lambda Layer ARNs to attach"
  type        = list(string)
  default     = []
}

variable "layer_name" {
  description = "Optional Lambda layer name"
  type        = string
  default     = ""
}

variable "layer_version" {
  description = "Optional Lambda layer version"
  type        = string
  default     = ""
}
