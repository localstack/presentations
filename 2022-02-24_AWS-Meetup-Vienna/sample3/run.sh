#!/bin/bash

terraform init
terraform apply

# Send message to SQS queue -> should trigger Lambda function
awslocal sqs send-message --queue-url http://localhost:4566/000000000000/terraform-sqs-test --message-body '{"hello":"world"}'
sleep 4

# Lambda has been invoked -> check log groups
awslocal logs describe-log-streams --log-group-name /aws/lambda/terraform_test_lambda

# Lambda has been invoked -> get log events from CloudWatch
awslocal logs get-log-events --log-group-name /aws/lambda/terraform_test_lambda --log-stream-name "2022/02/24/[LATEST]32423a7e"
