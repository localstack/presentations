# Deploy ECS application with Terraform

The sample application is based on a public [AWS sample app](https://github.com/aws-samples/ecs-apigateway-sample)
that deploys ECS containers with API Gateway to. 
See this AWS blog post for more details:
[Field Notes: Serverless Container-based APIs with Amazon ECS and Amazon API Gateway.](https://aws.amazon.com/blogs/architecture/field-notes-serverless-container-based-apis-with-amazon-ecs-and-amazon-api-gateway/)

## Steps

- Start LocalStack with `EXTRA_CORS_ALLOWED_ORIGINS=http://sample-app.s3.localhost.localstack.cloud:4566` and
`DISABLE_CUSTOM_CORS_APIGATEWAY=1`;
- Run `tflocal init; tflocal apply --auto-approve`;
- Run the `run.sh` script. It will build a react application and deploy it on a S3 bucket;
- Follow the URL output in the command line to interact with the application.
