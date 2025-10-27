terraform {
  backend "s3" {}
}

resource "aws_secretsmanager_secret" "this" {
  name        = var.name
  description = var.description
  recovery_window_in_days = var.recovery_window_in_days

  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string != null ? var.secret_string : jsonencode({})
}
