terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"
  s3_force_path_style = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    s3 = "http://localhost:4566"
    lambda = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "demo-bucket-localstack"
  force_destroy = true
}

resource "aws_lambda_function" "demo_lambda" {
  function_name = "demo_lambda"
  handler       = "lambda_function.handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_function_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function_payload.zip")
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.demo_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.demo_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.demo_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.demo_bucket.arn
} 