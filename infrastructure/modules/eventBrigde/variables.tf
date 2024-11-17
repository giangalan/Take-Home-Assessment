variable "event_name" {
  description = "The event name"
  type        = string
}

variable "schedule_expression" {
  description = "The expression for schedule rule"
  type = string
}

variable "lambda_arn" {
  description = "The lambda ARN"
  type = string
}

variable "function_name" {
  description = "The lambda name"
  type = string
}
