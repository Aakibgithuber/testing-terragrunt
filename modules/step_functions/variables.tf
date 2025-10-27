variable "name" {}
variable "region" {}
variable "definition" {}
variable "s3_bucket_name" {}
variable "role_name" {}
variable "project_name" {
  description = "Name of the project (used in resource naming)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}