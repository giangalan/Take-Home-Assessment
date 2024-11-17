resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = var.event_name
  schedule_expression = var.schedule_expression
}