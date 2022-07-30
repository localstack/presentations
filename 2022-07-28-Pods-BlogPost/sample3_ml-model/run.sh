#!/bin/bash

zip lambda.zip train.py
awslocal s3 mb s3://pods-test
awslocal s3 cp lambda.zip s3://pods-test/lambda.zip
awslocal s3 cp digits.rst s3://pods-test/digits.rst
awslocal s3 cp digits.csv.gz s3://pods-test/digits.csv.gz

awslocal lambda create-function --function-name func1 \
  --runtime python3.8 --role r1 --handler train.handler --timeout 600 \
   --code '{"S3Bucket":"pods-test","S3Key":"lambda.zip"}' \
  --layers arn:aws:lambda:us-east-1:446751924810:layer:python-3-8-scikit-learn-0-23-1:2

awslocal lambda invoke --function-name func1 /tmp/test.tmp