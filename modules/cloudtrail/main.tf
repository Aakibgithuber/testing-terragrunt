terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "${var.name}-${var.environment}-logs"
  force_destroy = true

  tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AWSCloudTrailAclCheck",
        Effect   = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action   = "s3:GetBucketAcl",
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.bucket}"
      },
      {
        Sid      = "AWSCloudTrailWrite",
        Effect   = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "this" {
  depends_on = [aws_s3_bucket_policy.cloudtrail_policy]

  name                          = var.name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${var.s3_bucket_name}/"]
    }
  }

  tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Project     = var.project_name
  }
}
