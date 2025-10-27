terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  layer_arn = var.layer_name != "" && var.layer_version != "" ? "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:layer:${var.layer_name}:${var.layer_version}" : null
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#  Allow Lambda to send messages to DLQ (SQS)
resource "aws_iam_role_policy" "lambda_dlq_policy" {
  name = "${var.function_name}-dlq-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "s3:*",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      }
    ]
  })
}

#  Lambda Function with optional DLQ integration
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename         = "${path.module}/${var.directory}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/${var.directory}/lambda.zip")

  environment {
    variables = {
      SFTP_HOST                = var.sftp_host
      SFTP_PORT                = var.sftp_port
      REGION                   = var.region
      APP_NAME                 = var.app_name
      ENVIRONMENT              = var.environment
      SFTP_SQL_DIR             = var.sftp_sql_dir
      SFTP_CONCURRENCY         = var.sftp_concurrency
      SFTP_POOL_SIZE           = var.sftp_pool_size
      SFTP_TEAMS_WEBHOOK_URL   = var.sftp_teams_webhook_url
    }
  }

# ✅ Optional Layer — only if provided
  layers = length(var.lambda_layers) > 0 ? var.lambda_layers : null

  # ✅ Dead Letter Queue Integration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dlq_policy
  ]
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 14
}

# Outputs
output "lambda_arn" {
  value = aws_lambda_function.this.arn
}
