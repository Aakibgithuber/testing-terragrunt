terraform {
  backend "s3" {}
}

# DynamoDB table to store sync_time or last_sync_time
resource "aws_dynamodb_table" "sync_time" {
  name         = "${var.project_name}-${var.environment}-sync-time"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sync-time"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

output "table_name" {
  value = aws_dynamodb_table.sync_time.name
}

output "table_arn" {
  value = aws_dynamodb_table.sync_time.arn
}
