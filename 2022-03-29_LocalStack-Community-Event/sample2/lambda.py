def handler(event, context):
    print("Hello from LocalStack!!")

    # list_buckets()


def list_buckets():
    import boto3
    client = boto3.client("s3")
    result = client.list_buckets()["Buckets"]
    print("Buckets:", result)
