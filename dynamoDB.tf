

# Create DynamoDB Table
resource "aws_dynamodb_table" "s3_uploaded_files" {
  name         = "s3_uploaded_files"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "filename"
    type = "S" # String type (Primary Key)
  }

  attribute {
    name = "uploaded_at"
    type = "S" # String type (Sort Key - Timestamp)
  }

  hash_key  = "filename"
  range_key = "uploaded_at"
}

# Update IAM Role to Allow Writing to DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda_dynamodb_policy"
  description = "Allows Lambda to write filenames to DynamoDB"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem"
      ],
      "Resource": "${aws_dynamodb_table.s3_uploaded_files.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# Lambda Function - Now Stores Filenames in DynamoDB (check main.tf)
