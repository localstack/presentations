#!/usr/bin/env sh

tflocal init
tflocal apply --auto-approve

# run test

awslocal s3 cp example-app.log s3://app-logs-structured/example-app-01.log

awslocal sqs receive-message --wait-time-seconds 20 \
	--queue-url http://localhost:4566/000000000000/alerts-queue \
	| jq -r ".Messages[0].Body"

awslocal sqs receive-message --wait-time-seconds 20 \
	--queue-url http://localhost:4566/000000000000/alerts-queue \
	| jq -r ".Messages[0].Body"
