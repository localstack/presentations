import json
import os

# TODO remove
if endpoint_url := os.getenv("AWS_ENDPOINT_URL"):
    os.environ["AWS_ENDPOINT_URL"] = endpoint_url = endpoint_url.replace(":443", ":4566").replace("https://", "http://")

import boto3
from botocore.client import Config

# configuration
alerts_queue_name = "alerts-queue"

# AWS SDK clients
s3 = boto3.client("s3", config=Config(s3={'addressing_style': 'path'}), endpoint_url=endpoint_url)
sqs = boto3.client("sqs", endpoint_url=endpoint_url)


# =============
# HELPER METHOD
# =============


def read_s3_object(bucket, key) -> str:
    data = s3.get_object(Bucket=bucket, Key=key)
    return data["Body"].read().decode("utf-8")


def read_changed_object(event) -> str:
    s3_event = event["Records"][0]["s3"]
    bucket = s3_event["bucket"]["name"]
    key = s3_event["object"]["key"]

    return read_s3_object(bucket, key)


# ==============
# Lambda handler
# ==============


def handler(event, context):

    print("HELLO World! AWS DACH hello!")

    if "Records" not in event:
        print("invocation not triggered by an event")
        return

    # resolve the queue to publish alerts to
    log_content = read_changed_object(event)

    print("log content")
    print(log_content)

    # parse structured log records
    records = [json.loads(line) for line in log_content.split("\n") if line.strip()]
    alerts = []

    alerts_queue_url = sqs.get_queue_url(QueueName=alerts_queue_name)['QueueUrl']

    for record in records:
        # filter log records to create alerts
        try:
            alert = None

            # TODO: adjust the here thresholds here
            if record['cpu'] >= 80:
                alert = {"timestamp": record['timestamp'], "level": "CRITICAL", "message": "Critical CPU utilization"}
            elif record['cpu'] >= 70:
                alert = {"timestamp": record['timestamp'], "level": "WARNING", "message": "High CPU utilization"}

            # break
            if alert:
                print("alert", alert)
                alerts.append(alert)
                sqs.send_message(MessageBody=json.dumps(alert), QueueUrl=alerts_queue_url)
        except KeyError:
            pass
