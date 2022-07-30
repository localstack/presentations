awslocal s3 mb s3://test
echo "hello world" > /tmp/hello-world
awslocal s3 cp /tmp/hello-world s3://test/hello-world
awslocal s3 ls s3://test/

awslocal sqs create-queue --queue-name test-q1
awslocal sqs send-message --queue-url \
  http://localhost:4566/000000000000/test-q1 \
  --message-body '{"hello":"world"}'
awslocal sqs receive-message \
  --queue-url http://localhost:4566/000000000000/test-q1


