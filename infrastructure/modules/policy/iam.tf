resource "aws_iam_role" "iam_lambda" {
  name = var.config.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "iam_lambda_policy" {
  name = var.policy_name
  role = aws_iam_role.iam_lambda.name
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "cloudwatch:PutMetricData"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}
