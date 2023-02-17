#!/bin/bash

zip -r lambda_function lambda_function.py lifecycle/

export REGION=us-east-1

export BUCKET_NAME=connectivity-management-example-for-aws-iot-core

awslocal s3api create-bucket --region ${REGION} --bucket ${BUCKET_NAME} --create-bucket-configuration LocationConstraint=${REGION}

awslocal s3 cp lambda_function.zip s3://${BUCKET_NAME}/lifecycle/lambda_function.zip

awslocal cloudformation create-stack \
  --region $REGION \
  --stack-name IoTLifeCycleEventStack \
  --template-body file://cfn.yaml \
  --capabilities CAPABILITY_IAM \
  --parameters ParameterKey=BucketName,ParameterValue=${BUCKET_NAME}

# Wait for stack to be created

awslocal cloudformation describe-stacks --region ${REGION} --stack-name IoTLifeCycleEventStack --query 'Stacks[*].StackStatus'

# Confirm the created stack

awslocal cloudformation list-stack-resources --region ${REGION} --stack-name IoTLifeCycleEventStack
