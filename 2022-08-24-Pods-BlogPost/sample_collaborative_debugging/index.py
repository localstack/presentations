import json
import boto3
import os

endpoint_url = f'http://{os.environ["LOCALSTACK_HOSTNAME"]}:{os.environ["EDGE_PORT"]}'
# region is wrong!! it should have been us-west-2
region = "eu-east-1" 
secret_name = "test-secret"

def handler(event, context):
    secrets_client = boto3.client('secretsmanager', region_name=region, endpoint_url=endpoint_url)
    result = secrets_client.get_secret_value(SecretId=secret_name)
    return {
        "Name": result["Name"],
        "SecretString": result["SecretString"],
        "ARN": result["ARN"]
    }   