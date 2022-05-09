#!/bin/bash

# step 1: run queries via web UI:

# CREATE TABLE users(id int, name varchar)
# INSERT INTO users(id, name) VALUES(100, 'Alice')
# INSERT INTO users(id, name) VALUES(200, 'Alex')
# SELECT * FROM users


# step 2: query data via the RDS Aurora query API

# get database ARN
dbArn=$(awslocal rds describe-db-instances | jq -r '.DBInstances[0].DBInstanceArn')

# execute statement
awslocal rds-data execute-statement --resource-arn $dbArn --secret-arn arn:aws:secretsmanager:$AWS_DEFAULT_REGION:000000000000:secret:test-123456 --sql 'SELECT 123'
awslocal rds-data execute-statement --resource-arn $dbArn --secret-arn arn:aws:secretsmanager:$AWS_DEFAULT_REGION:000000000000:secret:test-123456 --sql "INSERT INTO users(id,name) VALUES(300,'Bob')"
awslocal rds-data execute-statement --resource-arn $dbArn --secret-arn arn:aws:secretsmanager:$AWS_DEFAULT_REGION:000000000000:secret:test-123456 --sql "SELECT * FROM users"
