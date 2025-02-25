import json
import boto3
import os

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    print("Event: ", json.dumps(event))
    
    # Extract bucket and object details
    record = event['Records'][0]
    bucket_name = record['s3']['bucket']['name']
    object_key = record['s3']['object']['key']
    
    message = f"New file uploaded: s3://{bucket_name}/{object_key}"
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']

    # Send SNS notification
    sns_client.publish(TopicArn=sns_topic_arn, Message=message, Subject="New S3 File Uploaded")

    return {
        'statusCode': 200,
        'body': json.dumps('Notification Sent!')
    }
