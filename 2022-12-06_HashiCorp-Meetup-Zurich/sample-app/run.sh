#!/bin/bash

# Note: start up LocalStack with:
#  * EXTRA_CORS_ALLOWED_ORIGINS=http://sample-app.s3.localhost.localstack.cloud:4566
#  * DISABLE_CUSTOM_CORS_APIGATEWAY=1

STACK=stack1
CF_FILE=cloudformation-template-yaml/ecsapi-demo-cloudformation.yaml

test -e $CF_FILE || curl -o $CF_FILE https://pomatas-public-blogs.s3.amazonaws.com/ecsapi-demo-testapi/ecsapi-demo-cloudformation.yaml
sed -i "" -e 's|simonepomata/ecsapi-demo-foodstore|localstack.container-registry.com/library/foodstore|g' $CF_FILE
sed -i "" -e 's|simonepomata/ecsapi-demo-petstore|localstack.container-registry.com/library/foodstore|g' $CF_FILE

echo Deploying CloudFormation stack ...
awslocal cloudformation create-stack --stack-name $STACK --template-body file://$CF_FILE

for i in {1..10}; do
	if awslocal cloudformation describe-stacks --stack-name $STACK | grep CREATE_COMPLETE; then
		break
	fi
	echo Waiting for deployment to complete ...
	sleep 3
done

API_ID=$(awslocal apigatewayv2 get-apis | jq -r '.Items[] | select(.Name=="ecsapi-demo") | .ApiId')
POOL_ID=$(awslocal cognito-idp list-user-pools --max-results 1 | jq -r '.UserPools[0].Id')
CLIENT_ID=$(awslocal cognito-idp list-user-pool-clients --user-pool-id $POOL_ID | jq -r '.UserPoolClients[0].ClientId')

# perl -i -pe  "s/\d+\./$API_ID/g" client-application-react/src/App.js

# build Web UI assets and upload to local S3
(
  echo Building Web assets and uploading to local S3 bucket ...
  cd client-application-react
  test -e node_modules || npm i
  test -e build/index.html || npm run build
  awslocal s3 mb s3://sample-app
  awslocal s3 sync build s3://sample-app
)

URL="http://sample-app.s3.localhost.localstack.cloud:4566/index.html?stackregion=us-east-1&stackhttpapi=$API_ID&stackuserpool=$POOL_ID&stackuserpoolclient=$CLIENT_ID"
echo Please open the following link in your browser:
echo $URL
