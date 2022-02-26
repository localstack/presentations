#!/bin/bash

# start LocalStack with DATA_DIR=/tmp/ls-data enabled

# list available cloud pods
lpods list-pods

# initialize a new pod locally
lpods init --name test-pod

# register a pod with the platform backend
lpods register --name test-pod

# make a few more changes in the LocalStack instance ...

# push the pod to the backend
lpods push --name test-pod

# inject the pod state into the running instance
lpods inject --name test-pod

# check that the state has been injected properly ...
awslocal s3 ls
