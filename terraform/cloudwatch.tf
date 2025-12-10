resource "aws_cloudwatch_dashboard" "photo_pipeline" {
  dashboard_name = "PhotoPipelineDashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          region = "eu-west-1" # add region
          metrics = [
            ["PhotoPipeline", "ImagesProcessed"]
          ],
          period      = 60,
          stat        = "Sum",
          title       = "Images Processed",
          view        = "timeSeries",
          annotations = {} # required property
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          region = "eu-west-1" # add region
          metrics = [
            ["PhotoPipeline", "AnimalsDetected"]
          ],
          period      = 60,
          stat        = "Sum",
          title       = "Animals Detected",
          view        = "timeSeries",
          annotations = {} # required property
        }
      }
    ]
  })
}

# CloudWatch Alarm if Lambda is failing or animals are 0
resource "aws_cloudwatch_metric_alarm" "lambda_failures" {
  alarm_name          = "LambdaFailureAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm if Lambda function fails"
}

resource "aws_cloudwatch_metric_alarm" "no_animals_detected" {
  alarm_name          = "NoAnimalsDetectedAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "AnimalsDetected"
  namespace           = "PhotoPipeline"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if no animals detected in 5 minutes"
}