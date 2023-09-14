#!/bin/bash

export AWS_DEFAULT_REGION=us-east-1

# 1. create a local Lambda function
mkdir -p /tmp/python/
echo 'def handler(*args, **kwargs):' > /tmp/testlambda.py
echo '  print("Debug output from Lambda function")' >> /tmp/testlambda.py
(cd /tmp; zip testlambda.zip testlambda.py)
awslocal lambda create-function --function-name func1 --runtime python3.8 \
    --role arn:aws:iam::000000000000:role/r1 --handler testlambda.handler \
    --timeout 30 --zip-file fileb:///tmp/testlambda.zip

# 2. create an SQS queue locally in LocalStack
awslocal sqs create-queue --queue-name test-local-proxy

# 3. create event source mapping
awslocal lambda create-event-source-mapping \
    --function-name func1 \
    --batch-size 1 \
    --event-source-arn arn:aws:sqs:us-east-1:000000000000:test-local-proxy

# 4. send a message to the queue (triggers the Lambda function)
awslocal sqs send-message --queue-url http://localhost:4566/000000000000/test-local-proxy --message-body '{}'

# ---
# switch to remote/proxy mode:
# ---

# 5. create the same SQS queue in real AWS (requires AWS credentials)
aws sqs create-queue --queue-name test-local-proxy

# 6. start the AWS proxy extension (requires AWS credentials)
localstack -d aws proxy -c proxy.config

# next, go to the AWS console and put an item to the queue, see how it triggers a local Lambda!
