# SQS queue for S3 events
resource "aws_sqs_queue" "this" {
  name = var.queue_name

  redrive_policy = jsonencode({
    deadLetterTargetArn = var.dlq_arn
    maxReceiveCount     = 5 # message goes in DLQ after 5 failed processing attempts
  })

  depends_on = [
    var.s3_bucket_arn,
    var.dlq_arn
  ]
}

# Dead-letter queue for SQS
resource "aws_sqs_queue" "s3_events_dlq" {
  name = "${var.queue_name}-dlq"
}
