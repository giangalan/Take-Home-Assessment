variable "function_name" {
  description = "The function name"
  type        = string
}

variable "role_arn" {
  description = "The role ARN"
  type        = string
}

variable "config" {
  description = "The lambda configuration"
  type = any
}
