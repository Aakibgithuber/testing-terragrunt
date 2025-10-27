terraform {
  backend "s3" {}
}

# Lambda Layer Module
# Purpose: Creates reusable Lambda layers

resource "aws_lambda_layer_version" "this" {
  layer_name          = var.layer_name
  description         = var.description
  filename            = var.source_path
  source_code_hash    = filebase64sha256(var.source_path)
  compatible_runtimes = var.compatible_runtimes
}