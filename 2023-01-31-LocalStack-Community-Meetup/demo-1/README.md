# Deploy a minimal Terraform module in LocalStack

## Steps

- Start LocalStack;
- Install the `tflocal` wrapper with `pip install terraform-local`;
- Run `tflocal init` to initialize the provider;
- Run `tflocal plan` to have a view on the resources we are about to create;
- Run `tflocal apply` to actually create the resources;
- Verify that the resources have been created with `awslocal sqs list-queues`.
