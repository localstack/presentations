#!/bin/bash

# Demo for local cloud pods

# (1) create some state

awslocal s3 mb s3://bucket1
awslocal s3 mb s3://bucket2
awslocal sqs create-queue --queue-name queue1

# (2) create cloud pod (commit state)

localstack pod commit --name pod1
localstack pod inspect --name pod1

# (3) create some more state

awslocal sns create-topic --name topic1
awslocal iam create-user --user user1

# (4) update cloud pod (commit), inspect updated state

localstack pod commit --name pod1
localstack pod inspect --name pod1

# (5) restart LocalStack instance, then inject cloud pod

awslocal sqs list-queues
localstack pod inject --name pod1
awslocal sqs list-queues
