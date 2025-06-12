# S3 Event Processing with Lambda and Terraform

This project demonstrates how to set up an AWS Lambda function that processes S3 events using Terraform and LocalStack.

## Prerequisites

- LocalStack
- Terraform
- Python 3.9 or later
- AWS CLI (configured for LocalStack)

## Project Structure

```
.
├── README.md
├── lambda/
│   └── handler.py
└── terraform/
    └── main.tf
```

## Deployment

1. Make sure LocalStack is running
2. Deploy the infrastructure:
   ```bash
   cd terraform
   tflocal init
   tflocal apply -auto-approve
   ```

## Testing

To test the setup, you can upload a file to the S3 bucket:

```bash
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://demo-bucket/
```

Check the Lambda function logs:

```bash
aws --endpoint-url=http://localhost:4566 logs describe-log-groups
aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/s3-event-processor
``` 