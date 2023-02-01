# S3 trigger application deployed with Terraform

This Terraform module will deploy a simple application with 2 S3 buckets, a Lambda function and a S3 trigger
configuration. Refer to the [AWS documentation](https://docs.aws.amazon.com/lambda/latest/dg/with-s3-tutorial.html)
for more details.

## Steps

- Start LocalStack;
- Run the following `terraform init; terraform apply --auto-approve`;
- Copy an image into `img-bucket` S3 bucket with the following command: `awslocal s3 cp <path_to_jpg> s3://img-bucket`;
- Make sure a resized image has been uploaded in the second bucket with `awslocal s3 ls s3://img-bucket-resized`;

## Cloud Pods
- You can try to create a Cloud Pod from the actual state by running `localstack pod save file://<path_on_disk>`;
- Try to restart LocalStack and load the pod with `localstack pod load file://<path_on_disk>`
