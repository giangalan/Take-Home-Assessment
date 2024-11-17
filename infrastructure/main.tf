locals {
  lambdas     = merge([for f in fileset(path.module, "./environments/lambda/*.yaml") : yamldecode(file("${path.module}/${f}"))]...)
  policies    = merge([for f in fileset(path.module, "./environments/policy/*.yaml") : yamldecode(file("${path.module}/${f}"))]...)
  s3          = merge([for f in fileset(path.module, "./environments/s3/*.yaml") : yamldecode(file("${path.module}/${f}"))]...)
  eventBridge = merge([for f in fileset(path.module, "./environments/eventBrigde/*.yaml") : yamldecode(file("${path.module}/${f}"))]...)
}

module "eventBridge" {
  source   = "./modules/eventBrigde"
  for_each = local.eventBridge

  event_name          = each.key
  schedule_expression = each.value
  function_name = data.aws_lambda_function.health_check_lambda.function_name
  lambda_arn = data.aws_lambda_function.health_check_lambda.arn
}

module "lambda" {
  source   = "./modules/lambda"
  for_each = local.lambdas

  function_name = each.key
  config        = each.value
  role_arn      = data.aws_iam_role.lambda_role.arn
  depends_on    = [module.policy]
}

module "policy" {
  source   = "./modules/policy"
  for_each = local.policies

  policy_name = each.key
  config      = each.value
}

data "aws_lambda_function" "health_check_lambda" {
  function_name = "healthcheck-lambda"
  depends_on = [module.lambda]
}

data "aws_iam_role" "lambda_role" {
  name       = "healthcheck-lambda-role"
  depends_on = [module.policy]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../processing_code"  # Path to the directory containing the Lambda code
  output_path = "./processing_code.zip"
}

module "s3" {
  source   = "./modules/s3"
  for_each = local.s3

  bucket_name = each.key
}

