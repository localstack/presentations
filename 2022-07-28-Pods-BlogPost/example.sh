#!/bin/bash

# create the queue
queue_url=$(awslocal sqs create-queue --queue-name test-queue | jq .QueueUrl | xargs) 

echo "Created queue URL: $queue_url"

queue_arn=$(awslocal sqs get-queue-attributes --queue-url $queue_url \
        --attribute-name QueueArn | jq .Attributes.QueueArn | xargs)

echo "Queue ARN: $queue_arn"

# create lambda function
awslocal lambda create-function --function-name my-function \
        --zip-file fileb://function.zip --handler index.handler --runtime python3.8 \
        --role arn:aws:iam::000000000000:role/lambda-ex

# setup lambda connection
awslocal lambda create-event-source-mapping --event-source-arn $queue_arn --function-name my-function 

# list the event-source mappings
awslocal lambda list-event-source-mappings

# create a secret
awslocal secretsmanager create-secret --name test-secret --secret-string my-secret-string

# sends a message to the queue
awslocal sqs send-message --queue-url $queue_url \
        --message-body "Message example" \
        --message-attributes file://message.json