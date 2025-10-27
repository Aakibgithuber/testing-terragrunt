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

variable "source_path" {
  description = "Path to the layer zip file"
  type        = string
}