# Simple script that illustrates IAM enforcement in LocalStack, and our "Explainable IAM" feature

# Note: make sure to start LocalStack with ENFORCE_IAM=1 enabled, then
#  enable the IAM Policy Stream in the LS Web application.

# create topic and queue
awslocal sns create-topic --name test-topic
awslocal sqs create-queue --queue-name test-queue

# subscribe queue to topic
awslocal sns subscribe --topic-arn arn:aws:sns:us-east-1:000000000000:test-topic \
  --protocol sqs --notification-endpoint arn:aws:sqs:us-east-1:000000000000:test-queue

# publish a message to topic
awslocal sns publish --topic-arn arn:aws:sns:us-east-1:000000000000:test-topic \
  --message '{"foo": "bar"}'

# attempt to receive a message - will be empty, due to missing IAM policy
awslocal sqs receive-message \
  --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/test-queue

# update queue with IAM policy to grant sqs:SendMessage access to the SNS topic
awslocal sqs set-queue-attributes \
  --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/test-queue \
  --attributes file://attributes.json
