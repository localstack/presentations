#!/bin/bash

# start LocalStack with EC2_VM_MANAGER=docker

# list local EC2 Docker images (pseudo-AMIs)
docker images | grep localstack-ec2

# list EC2 images (should include EC2 Docker images)
awslocal ec2 describe-images

# run an instance as EC2 container
awslocal ec2 run-instances --image-id ami-1234

# ssh into the instance (determine port from "docker ps")
ssh -p 51096 root@localhost

# look up instance ID
instId=$(awslocal ec2 describe-instances | jq -r '.Reservations[0].Instances[0].InstanceId')

# create snapshot of instance (creates new Docker image)
awslocal ec2 create-image --instance-id $instId --name snapshot1

# lookup AMI of new snapshot image
docker images | grep localstack-ec2

# launch another instance from this image
awslocal ec2 run-instances --image-id ami-36380d75

# ssh into the new instance ...
