variable "name" {
  description = "Name of the CloudTrail"
  type        = string
}

variable "environment" {
  description = "Environment (e.g. dev, prod)"
  type        = string
}

variable "s3_bucket_name" {
  description = "Target S3 bucket to monitor for PutObject events"
  type        = string
}

variable "project_name" {
  description = "Name of the project (used in resource naming)"
  type        = string
}