# ----
# configure providers to use local endpoints
# ----
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
//  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://localhost.localstack.cloud:4566"  # used for hostname-based bucket addressing
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

# ----
# S3 bucket
# ----

resource "aws_s3_bucket" "test-bucket" {
  bucket = "my-bucket"
}

# ----
# SQS queue
# ----

resource "aws_sqs_queue" "test_queue" {
  name             = "terraform-sqs-test"
}

# ----
# Kinesis stream
# ----

//resource "aws_kinesis_stream" "test_stream" {
//  name             = "terraform-kinesis-test"
//  shard_count      = 1
//  retention_period = 48
//}

# ----
# IAM roles and policies
# ----

resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = "${aws_iam_role.lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "s3:ListBucket",
    "Resource": "arn:aws:s3:::example_bucket"
  }
}
EOF
}

resource "aws_iam_role" "lambda" {
  name = "demo-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "s3:ListBucket",
    "Resource": "arn:aws:s3:::example_bucket"
  }
}
EOF
}

# ----
# Lambda function
# ----

resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda.zip"
  function_name = "terraform_test_lambda"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "lambda.hello"
  runtime       = "nodejs12.x"
  source_code_hash = "${filebase64sha256("lambda.zip")}"
}

# ----
# Lambda event source mapping from SQS queue / Kinesis stream
# ----

resource "aws_lambda_event_source_mapping" "mapping2" {
  event_source_arn  = aws_sqs_queue.test_queue.arn
  function_name     = aws_lambda_function.test_lambda.arn
  starting_position = "LATEST"
}

//resource "aws_lambda_event_source_mapping" "mapping1" {
//  event_source_arn  = aws_kinesis_stream.test_stream.arn
//  function_name     = aws_lambda_function.test_lambda.arn
//  starting_position = "LATEST"
//}
