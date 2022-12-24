#!/bin/bash

zip lambda.zip train.py
zip infer.zip infer.py

# push training data to S3
awslocal s3 mb s3://pods-test
awslocal s3 cp lambda.zip s3://pods-test/lambda.zip
awslocal s3 cp infer.zip s3://pods-test/infer.zip
awslocal s3 cp digits.rst s3://pods-test/digits.rst
awslocal s3 cp digits.csv.gz s3://pods-test/digits.csv.gz

# define lamba function to training the ML data
awslocal lambda create-function --function-name ml-train \
  --runtime python3.8 --role r1 --handler train.handler --timeout 600 \
   --code '{"S3Bucket":"pods-test","S3Key":"lambda.zip"}' \
   --layers arn:aws:lambda:us-east-1:446751924810:layer:python-3-8-scikit-learn-0-22-0:3

awslocal lambda create-function --function-name ml-predict \
  --runtime python3.8 --role r1 --handler infer.handler --timeout 600 \
   --code '{"S3Bucket":"pods-test","S3Key":"infer.zip"}' \
   --layers arn:aws:lambda:us-east-1:446751924810:layer:python-3-8-scikit-learn-0-22-0:3

# invoke the lambda function
awslocal lambda invoke --function-name ml-train test.tmp

awslocal lambda invoke --function-name ml-predict test.tmp

# create a Cloud Pod and make it public
localstack pod save ml-pod
localstack pod save ml-pod --visibility public
