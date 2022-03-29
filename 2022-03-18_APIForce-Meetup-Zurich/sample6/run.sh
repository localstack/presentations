#!/bin/bash

# demo: local S3 mounting (mounting local folders as buckets)

# start localstack with S3_DIR enabled:
S3_DIR=/tmp/s3-buckets localstack start

# list buckets
awslocal s3 ls
