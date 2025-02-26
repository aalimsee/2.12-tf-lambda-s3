Assignment 2.12 Function as a Service (Lambda Function)


Question 1
Purpose of the Execution Role on the Lambda Function
The execution role (IAM role assigned to Lambda) defines what AWS services the function can interact with. It is crucial because:
It grants permissions for Lambda to read objects from S3 (for processing uploaded files).
It allows writing logs to Amazon CloudWatch for monitoring and debugging.
If configured, it lets Lambda publish messages to SNS for notifications.


Question 2
Purpose of the Resource-Based Policy on the Lambda Function
A resource-based policy is needed when an external AWS service (like S3) invokes the Lambda function. It:
Grants S3 permission to trigger the Lambda function when a file is uploaded.
Ensures only the intended S3 bucket can invoke the function (security best practice).
Without this, S3 cannot invoke the Lambda function, even if the Lambda execution role allows S3 access.


Question 3
1. Needed update on the Execution Role (If Lambda needs to upload a file to S3)
If the Lambda function also needs to upload files to an S3 bucket, we must update the execution role to allow:
s3:PutObject → Grants permission to upload files.
s3:ListBucket (Optional) → Allows listing objects if required.
The IAM policy should specify the correct bucket ARN and object prefix to avoid over-permissioning.
Example with “s3:GetObject”. Abovement will need to be included. 


2. Needed update to the Resource-Based Policy (If Any)
A resource-based policy is NOT needed in this case.
Why? Lambda is calling S3, not the other way around.
The execution role's permissions are sufficient for uploading files.
Resource-based policies are only required when an external AWS service (like S3) needs to call Lambda.

Summary
Scenario
Required?
Lambda reads from S3 (triggered by S3)
✅ Execution Role (Read)
✅ Resource-based Policy (Allow S3 to invoke Lambda)
Lambda uploads a file to S3
✅ Execution Role (Write)
❌ No resource-based policy needed



Example of IAM policies
Here are the specific IAM policies needed for both scenarios:

Execution Role Policy (Lambda Needs to Read from S3 & Be Triggered by S3)
This policy allows:
Reading objects from S3 (for processing uploaded files).
Writing logs to CloudWatch (for debugging).
Publishing SNS messages (if notifications are needed).
Execution Role Policy
json

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::your-source-bucket-name/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "arn:aws:sns:us-east-1:123456789012:your-sns-topic"
    }
  ]
}


Resource-Based Policy (Allow S3 to Invoke Lambda)
This policy is attached to the Lambda function itself to allow S3 to trigger it.
Resource-Based Policy
json

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:your-lambda-function",
      "Condition": {
        "ArnLike": {
          "AWS:SourceArn": "arn:aws:s3:::your-source-bucket-name"
        }
      }
    }
  ]
}


Execution Role Policy (If Lambda Needs to Upload to S3)
If Lambda also needs to upload a file to an S3 bucket, update the execution role to allow:
Writing objects to S3 (s3:PutObject).
(Optional) Listing objects (s3:ListBucket).
Updated Execution Role Policy
json

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::your-source-bucket-name/*",
        "arn:aws:s3:::your-destination-bucket-name/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}

No additional resource-based policy is needed for S3 uploads, since Lambda is initiating the action.

Summary of Policy Needs
Scenario
Execution Role Policy Needed?
Resource-Based Policy Needed?
Lambda reads from S3 (triggered by S3)
✅ Yes (Read from S3)
✅ Yes (Allow S3 to trigger Lambda)
Lambda uploads files to S3
✅ Yes (Write to S3)
❌ No


Github
https://github.com/aalimsee/2.12-tf-lambda-s3.git 
