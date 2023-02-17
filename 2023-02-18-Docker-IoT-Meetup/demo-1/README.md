# Deploy a minimal Terraform module in LocalStack

Deploy a static website in a S3 bucket using Terraform in LocalStack.

## Steps

- Start LocalStack
- Install the `tflocal` wrapper with `pip install terraform-local`
- Run `tflocal init` to initialize the provider
- Run `tflocal plan` to have a view on the resources we are about to create
- Run `tflocal apply` to actually create the resources
- Verify that the resources have been created with `awslocal s3 ls`
- Navigate to your static website endpoint in your browser (if your bucket is named `test`, then [test.s3-website.localhost.localstack.cloud:4566](http://test.s3-website.localhost.localstack.cloud:4566/))
