variable "layer_name" {
  description = "Name of the Lambda layer"
  type        = string
}

variable "description" {
  description = "Description of the layer"
  type        = string
  default     = ""
}

variable "compatible_runtimes" {
  description = "List of compatible runtimes"
  type        = list(string)
  default     = ["nodejs20.x", "nodejs18.x"]
}

variable "s3_bucket" {
  description = "S3 bucket containing the layer zip (optional)"
  default     = ""
}
variable "s3_key" {
  description = "S3 key for layer zip (optional)"
  default     = ""
}
