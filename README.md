

# 2.12 Lambda Function
Terraform script to deploy an AWS Lambda function that triggers when a file is created in an S3 bucket. The setup includes:

- An S3 bucket to store files
- A Lambda function to process file uploads
- An IAM role and policy for Lambda to access S3
- An S3 event notification to trigger Lambda

You'll need to replace placeholders like <YOUR_BUCKET_NAME> and provide a Lambda deployment package (.zip file).

# Overall Flow
- A user uploads a file to the S3 bucket.
- S3 triggers the Lambda function.
The Lambda function:
- Extracts the bucket name and file name from the event.
- Sends a notification to the SNS topic.
- The SNS topic sends an email notification to the subscribed email.

# Lambda_function.zip
lambda_function.zip is the deployment package for your AWS Lambda function. It contains your function code and any dependencies it needs.

# How to Create lambda_function.zip
Write the Lambda Function Code
Create a file called lambda_function.py:


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

Package the Code
Run the following command in the terminal:

    zip lambda_function.zip lambda_function.py

Upload the Zip File to Terraform Directory
Ensure lambda_function.zip is in the same directory as your Terraform script.

# {bucket_name} and {object_key}
{bucket_name} and {object_key} are placeholders representing values from the S3 event that triggers the Lambda function.

-bucket_name: The name of the S3 bucket where the file was uploaded.
-object_key: The path (key) of the newly uploaded file within the bucket.

Example Event from S3:
When a file is uploaded, S3 sends an event to Lambda in this format (json):

    {
    "Records": [
        {
        "s3": {
            "bucket": {
            "name": "my-s3-bucket"
            },
            "object": {
            "key": "uploads/myfile.txt"
            }
        }
        }
    ]
    }

From this event:

{bucket_name} would be "my-s3-bucket"
{object_key} would be "uploads/myfile.txt"
Your Lambda function extracts these values to process the event and send notifications.