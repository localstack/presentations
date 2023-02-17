# Basic IoT Entities in LocalStack

Simple demo application illustrating usage of IoT APIs in LocalStack.

## Steps

- Start LocalStack
- Install the `awslocal` CLI with `pip install awscli-local`
- Run `awslocal cloudformation create-stack --stack-name test-iot --template-body file://iot.cf.yml` to create the IoT entities
- Run `awslocal iot list-things` to list the things
- Run `awslocal iot list-policies` to list the policies
- Run `awslocal iot create-job --job-id j1 --targets t1` to create a job
- Run `awslocal iot list-jobs` to list the jobs
- Create a virtual environment with `virtualenv` and activate it
- Install the dependencies with `pip install -r requirements.txt`
- Run `python3 mqtt-test.py` to create a subscriber, create a publisher, and publish a message
