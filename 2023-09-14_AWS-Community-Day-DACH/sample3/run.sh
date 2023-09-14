#!/bin/bash

# 1. start LocalStack with ENFORCE_IAM=1 enabled

# 2. start the IAM live policy agent
localstack aws iam summary -f

# 3. create some state in LocalStack, observe the output of IAM live
awslocal s3 mb s3://test123
awslocal sqs create-queue --queue-name q1
