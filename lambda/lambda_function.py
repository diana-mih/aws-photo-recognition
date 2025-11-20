import json
from decimal import Decimal
import boto3

# Initialize boto3
s3_client = boto3.client('s3')
rekognition = boto3.client('rekognition', region_name='eu-west-1')  # Region where Rekognition is available
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('photos_metadata')

def lambda_handler(event, context):
    for record in event['Records']:
        # Parse SQS body
        body = json.loads(record['body'])
        s3_info = body['detail']['object']
        bucket_name = body['detail']['bucket']['name']
        object_key = s3_info['key']
        
        # Get timestamp
        timestamp = body.get('time') or body['detail'].get('eventTime') or ''
        
        print(f"Processing image s3://{bucket_name}/{object_key} at {timestamp}")
        
        try:
            # Rekognition detect labels
            response = rekognition.detect_labels(
                Image={
                    'S3Object': {
                        'Bucket': bucket_name,
                        'Name': object_key
                    }
                },
                MaxLabels=10,
                MinConfidence=70
            )
            
            # Only keep relevant data
            detected_animals = []
            for label in response['Labels']:
                if label['Name'].lower() in ['dog', 'cat']:
                    detected_animals.append({
                        'name': label['Name'],
                        'confidence': float(label['Confidence'])  # float, nu Decimal
                    })
            
            # Store results in DynamoDB
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
            print(f"Image {object_key} processed successfully.")
            
        except Exception as e:
            print(f"Error processing {object_key}: {str(e)}")
            
    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete')
    }
