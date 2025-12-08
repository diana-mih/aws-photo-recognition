# SQS queue for S3 events
resource "aws_sqs_queue" "s3_events" {
  name = "s3-events-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.s3_events_dlq.arn
    maxReceiveCount     = 5 # message goes in DLQ after 5 failed processing attempts
  })

  depends_on = [
    module.input_bucket,
    aws_sqs_queue.s3_events_dlq
  ]
}

# Dead-letter queue for SQS
resource "aws_sqs_queue" "s3_events_dlq" {
  name = "s3-events-dlq"
}
