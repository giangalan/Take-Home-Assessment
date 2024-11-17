output "lambda_arn" {
  description = "The lambda arn"
  value       = aws_lambda_function.health_check_lambda.arn
}
