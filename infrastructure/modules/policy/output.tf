output "role_arn" {
  description = "The role arn"
  value       = aws_iam_role.iam_lambda.arn
}
