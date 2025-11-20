# S3 Bucket for photo input
resource "aws_s3_bucket" "photos_input" {
  bucket = "diana-photo-pipeline-input-001"

  tags = {
    Project = "photo-pipeline"
  }

}

# Enable EventBridge notifications for the S3 bucket
resource "aws_s3_bucket_notification" "enable_eventbridge" {
  bucket = "diana-photo-pipeline-input-001"

  eventbridge = true

}