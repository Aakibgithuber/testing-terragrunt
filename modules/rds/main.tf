terraform {
  backend "s3" {}
}

resource "aws_db_instance" "postgres" {
  identifier         = "${var.project_name}-${var.environment}-rds"
  engine             = var.db_engine
  engine_version     = var.engine_version
  instance_class     = var.instance_class
  allocated_storage  = var.allocated_storage
  db_name            = var.db_name
  username           = var.db_username
  password           = var.db_password
  skip_final_snapshot = true
  publicly_accessible = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds"
    Environment = var.environment
  }
}

output "db_host" {
  value = aws_db_instance.postgres.address
}

# Store RDS credentials in Secrets Manager
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${var.project_name}-${var.environment}-rds-credentials"
  description = "RDS credentials for ${var.environment} environment"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    database = aws_db_instance.postgres.db_name
  })
}

output "rds_secret_arn" {
  value = aws_secretsmanager_secret.rds_credentials.arn
}

