# EventBridge rule to capture S3 object creation events
resource "aws_cloudwatch_event_rule" "s3_object_created" {
  name        = var.rule_name
  description = "Trigger when a new object is uploaded to S3"

  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [var.bucket_name]
      }
    }
  })
}

# SQS as target
resource "aws_cloudwatch_event_target" "to_sqs" {
  rule      = aws_cloudwatch_event_rule.s3_object_created.name
  target_id = "send-to-sqs"
  arn       = var.sqs_queue_arn
}

# Allow EventBridge to send messages to SQS
resource "aws_sqs_queue_policy" "allow_eventbridge" {
  queue_url = var.sqs_queue_url

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "sqspolicy",
    "Statement" : [
      {
        "Sid" : "AllowEventBridgeSendMessage",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Action" : "sqs:SendMessage",
        "Resource" : var.sqs_queue_arn
      }
    ]
  })
}