
locals {
    YOUR_BUCKET_NAME = "aalimsee-lambda"
    YOUR_EMAIL_ADDRESS = "aaron.limse@hotmail.com"
}

# Create an S3 Bucket
resource "aws_s3_bucket" "lambda_trigger_bucket" {
  bucket = local.YOUR_BUCKET_NAME
}

# Set Up SNS for Email Notifications
resource "aws_sns_topic" "lambda_notifications" {
  name = "lambda_s3_notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.lambda_notifications.arn
  protocol  = "email"
  endpoint  = local.YOUR_EMAIL_ADDRESS # Change to your email
}

# Create IAM Role and Policy for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_s3_trigger_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Grants Lambda permission to assume a role for execution. Grants Lambda permissions: Read from the S3 bucket. Write logs to CloudWatch. Publish messages to SNS.
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda_s3_policy"
  description = "Allows Lambda to read from S3 and publish to SNS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::local.YOUR_BUCKET_NAME/*"
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
      "Resource": "${aws_sns_topic.lambda_notifications.arn}"
    }
  ]
}
EOF
}

# Attaches the policy to the Lambda IAM role.
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

# Create the Lambda Function. Deploys the Lambda function from lambda_function.zip. Sets an environment variable SNS_TOPIC_ARN to send SNS notifications.
resource "aws_lambda_function" "s3_trigger_lambda" {
  filename      = "lambda_function.zip" # Ensure this file is present
  function_name = "aalimsee_s3_file_trigger"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.lambda_notifications.arn
    }
  }
}

# Configure S3 to Trigger Lambda. Configures S3 to trigger Lambda whenever a new file is uploaded.
resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
  bucket = aws_s3_bucket.lambda_trigger_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_trigger_lambda.arn
    events             = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_trigger_bucket.arn
}
