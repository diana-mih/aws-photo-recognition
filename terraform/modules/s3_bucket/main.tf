resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Project = "photo-pipeline"
  }
}


# Enable EventBridge notifications for the S3 bucket
resource "aws_s3_bucket_notification" "enable_eventbridge" {
  bucket = var.bucket_name

  eventbridge = true

}