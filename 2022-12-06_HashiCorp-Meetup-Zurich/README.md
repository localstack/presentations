# HashiCorp User Group (HUG) Meetup Zurich Talk - 2022-12-06

* Talk details: ...
* Slides: ...
* Recording: ...

## Harbor/LocalStack Demo application

In this demo, we illustrate how to use [Harbor](https://goharbor.io) image registry in combination with LocalStack, for running containerized AWS apps on your local machine.
The entire stack for the infrastructure and application are defined and deployed via Terraform.

### Serverless Container-based APIs with Amazon ECS and Amazon API Gateway

The sample application is based on a public [AWS sample app](https://github.com/aws-samples/ecs-apigateway-sample) that deploys ECS containers with API Gateway to. See this AWS blog post for more details: [Field Notes: Serverless Container-based APIs with Amazon ECS and Amazon API Gateway](https://aws.amazon.com/blogs/architecture/field-notes-serverless-container-based-apis-with-amazon-ecs-and-amazon-api-gateway/).
 
[architecture](sample-app/architecture.png)

### Prerequisites

* Docker
* LocalStack (Pro version)
* Terraform

### Configuration

The app requires the following configs to be set in the LocalStack environment:
* `EXTRA_CORS_ALLOWED_ORIGINS=http://sample-app.s3.localhost.localstack.cloud:4566` 
* `DISABLE_CUSTOM_CORS_APIGATEWAY=1`

### Installing and starting the app

The app can be deployed via the shell run script:
```
$ ./run.sh
```

### Starting the app

Details following soon ...