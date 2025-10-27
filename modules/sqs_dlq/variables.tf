variable "name" {
  type        = string
  description = "Base name of the DLQ"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, prod)"
}