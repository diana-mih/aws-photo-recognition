output "lambda_function_arn" {
  value = aws_lambda_function.s3_events_processor.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
