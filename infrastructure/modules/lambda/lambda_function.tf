resource "aws_lambda_function" "health_check_lambda" {
  function_name = var.function_name
  runtime       = var.config.runtime
  handler       = var.config.handler
  role          = var.role_arn
  architectures = try(var.config.architecture, "x86_64")
  filename = var.config.filename
  timeout  = var.config.timeout
  dynamic "environment" {
    for_each = try({ config = var.config.environment }, {})
    content {
      variables = environment.value
    }
  }
}


