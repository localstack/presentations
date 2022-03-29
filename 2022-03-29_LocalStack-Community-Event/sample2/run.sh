#!/bin/bash

# start LocalStack with LAMBDA_REMOTE_DOCKER=0

# create Lambda function with __local__ bucket mount
awslocal lambda create-function --function-name hot-reload --code '{"S3Bucket":"__local__","S3Key":"'$PWD'"}' --handler lambda.handler --runtime python3.7 --role r1

# invoke function
awslocal lambda invoke --function-name hot-reload /tmp/lambda.out

# --> change handler in lambda.js, then invoke function again
