import json
import boto3
import logging

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3_client = boto3.client('s3')
rekognition = boto3.client('rekognition', region_name='eu-west-1')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('photos_metadata')
cloudwatch = boto3.client('cloudwatch')  # CloudWatch client for custom metrics

def send_metrics(num_animals):
    """
    Send custom CloudWatch metrics: number of images processed and animals detected.
    """
    try:
        # Metric for one image processed
        cloudwatch.put_metric_data(
            Namespace='PhotoPipeline',
            MetricData=[
                {
                    'MetricName': 'ImagesProcessed',
                    'Value': 1,
                    'Unit': 'Count'
                },
                {
                    'MetricName': 'AnimalsDetected',
                    'Value': num_animals,
                    'Unit': 'Count'
                }
            ]
        )
        logger.info(f"Sent CloudWatch metrics: 1 image processed, {num_animals} animals detected")
    except Exception as e:
        logger.error(f"Error sending metrics to CloudWatch: {str(e)}", exc_info=True)

def analyze_image(bucket_name, object_key, s3_info, timestamp):
    """
    Analyze the image using Rekognition and store results in DynamoDB.
    """
    try:
        logger.info(f"Starting analysis for image s3://{bucket_name}/{object_key}")

        response = rekognition.detect_labels(
            Image={'S3Object': {'Bucket': bucket_name, 'Name': object_key}},
            MaxLabels=10,
            MinConfidence=70
        )

        detected_animals = [
            {'name': label['Name'], 'confidence': float(label['Confidence'])}
            for label in response['Labels']
            if label['Name'].lower() in ['dog', 'cat']
        ]

        table.put_item(
            Item={
                'object_key': object_key,
                'bucket': bucket_name,
                'size': s3_info['size'],
                'etag': s3_info['etag'],
                'timestamp': timestamp,
                'detected_animals': json.dumps(detected_animals)
            }
        )

        logger.info(f"Image {object_key} processed successfully with {len(detected_animals)} animals detected.")

        # Send metrics to CloudWatch
        send_metrics(len(detected_animals))

    except Exception as e:
        logger.error(f"Error analyzing image {object_key}: {str(e)}", exc_info=True)

def process_s3_event(event_record):
    """
    Process a single SQS/EventBridge record containing S3 image information.
    """
    body = json.loads(event_record['body'])
    s3_info = body['detail']['object']
    bucket_name = body['detail']['bucket']['name']
    object_key = s3_info['key']
    timestamp = body.get('time') or body['detail'].get('eventTime') or ''

    logger.info(f"Received event for s3://{bucket_name}/{object_key} at {timestamp}")

    analyze_image(bucket_name, object_key, s3_info, timestamp)

def lambda_handler(event, context):
    """
    Main Lambda handler: iterate over all incoming records and process each.
    """
    for record in event['Records']:
        process_s3_event(record)

    logger.info("Processing complete for all records.")
    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete')
    }
