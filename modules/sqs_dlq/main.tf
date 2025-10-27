terraform {
  backend "s3" {}
}

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name}-${var.environment}-dlq"
  message_retention_seconds = 1209600  # 14 days
  visibility_timeout_seconds = 30

  tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}

output "queue_arn" {
  value = aws_sqs_queue.dlq.arn
}

output "queue_url" {
  value = aws_sqs_queue.dlq.id
}
