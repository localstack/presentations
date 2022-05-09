#!/bin/bash


# Note: start up LocalStack with EXTRA_CORS_ALLOWED_ORIGINS=http://localhost:3000

# Note: in order to enable email sending for Cognito, spin up mailhog:
#  docker run -it -d --rm -p 1025:1025 -p 8025:8025 mailhog/mailhog
# ... then start LocalStack with the following configs:
#  SMTP_HOST=host.docker.internal:1025
#  SMTP_EMAIL=test@localstack.cloud
#  SMTP_USER=test
#  SMTP_PASS=test


STACK=stack1
CF_FILE=cloudformation-template-yaml/ecsapi-demo-cloudformation.yaml

test -e $CF_FILE || curl -o $CF_FILE https://pomatas-public-blogs.s3.amazonaws.com/ecsapi-demo-testapi/ecsapi-demo-cloudformation.yaml
sed -i "" -e 's|simonepomata/ecsapi-demo-foodstore|localstack/ecsapi-demo-foodstore|g' $CF_FILE
sed -i "" -e 's|simonepomata/ecsapi-demo-petstore|localstack/ecsapi-demo-petstore|g' $CF_FILE

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

URL="http://localhost:3000/?stackregion=us-east-1&stackhttpapi=$API_ID&stackuserpool=$POOL_ID&stackuserpoolclient=$CLIENT_ID"
echo Please open the following link in your browser:
echo $URL
# open $URL
