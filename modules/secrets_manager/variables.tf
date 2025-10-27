variable "name" {
  type = string
}

variable "secret_string" {
  type = string
  default = null
}

variable "description" {
  type    = string
  default = "Managed by Terraform"
}

variable "recovery_window_in_days" {
  type    = number
  default = 0
}