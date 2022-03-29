#!/bin/bash

# -------
# Part 1: Deploy Lambda in real AWS
# -------

# create Lambda zip file
zip lambda.zip lambda.py

# create Lambda function with IAM role
AWS_ACCOUNT_ID=...
aws iam create-role --role-name test-lambda --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'
aws iam attach-role-policy --role-name test-lambda --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws lambda create-function --function-name test-apiforce --zip-file fileb://lambda.zip --handler lambda.handler --runtime python3.7 --role "arn:aws:iam::${AWS_ACCOUNT_ID}:role/test-lambda" --timeout 10
aws lambda list-functions

# invoke Lambda function
aws lambda invoke --function-name test-apiforce /tmp/lambda.out

# update Lambda function code (after re-creating the zip file)
aws lambda update-function-code --function-name test-apiforce --zip-file fileb://lambda.zip

# -------
# Part 2: Run Lambda in LocalStack, with local code mounting
# -------

# start LocalStack with LAMBDA_REMOTE_DOCKER=0

# create Lambda function with __local__ bucket mount
awslocal lambda create-function --function-name hot-reload --code '{"S3Bucket":"__local__","S3Key":"'$PWD'"}' --handler lambda.handler --runtime python3.7 --role r1

# invoke function
awslocal lambda invoke --function-name hot-reload /tmp/lambda.out

# --> change handler in lambda.js, then invoke function again
