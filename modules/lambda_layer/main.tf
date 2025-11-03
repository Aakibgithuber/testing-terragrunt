terraform {
  backend "s3" {}
}

# Lambda Layer Module
# Purpose: Creates reusable Lambda layers

resource "aws_lambda_layer_version" "this" {
  layer_name          = var.layer_name
  description         = var.description

  # Choose between local file or S3
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key
  compatible_runtimes = var.compatible_runtimes
  source_code_hash = timestamp()
}