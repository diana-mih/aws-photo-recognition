output "event_rule_arn" {
  value = aws_cloudwatch_event_rule.s3_object_created.arn
}

output "event_rule_name" {
  value = aws_cloudwatch_event_rule.s3_object_created.name
}

output "event_target_id" {
  value = aws_cloudwatch_event_target.to_sqs.target_id
}
