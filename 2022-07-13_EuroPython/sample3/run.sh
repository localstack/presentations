#!/bin/bash

# bootstrap and deploy the CDK stack
cdklocal bootstrap
cdklocal deploy

# list AppSync GraphQL APIs
awslocal appsync list-graphql-apis

# get API ID
apiId=$(awslocal appsync list-graphql-apis | jq -r '.graphqlApis[0].apiId')

# get API key
apiKey=$(awslocal appsync list-api-keys --api-id=$apiId | jq -r '.apiKeys[0].id')

# save item via GraphQL to DynamoDB
curl -H "x-api-key: $apiKey" -d '{"query":"mutation{save(name:\"test1\"){name, itemsId}}"}' -H 'content-type: application/json' http://localhost:4566/graphql/$apiId
itemId=$(curl -H "x-api-key: $apiKey" -d '{"query":"mutation{save(name:\"test2\"){name, itemsId}}"}' -H 'content-type: application/json' http://localhost:4566/graphql/$apiId | jq -r .data.save.itemsId)

# retrieve item via GraphQL from DynamoDB
curl -H "x-api-key: $apiKey" -d '{"query":"query{getOne(itemsId:\"'$itemId'\"){name}}"}' -H 'content-type: application/json' http://localhost:4566/graphql/$apiId
