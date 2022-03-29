def handler(event, context):
    print("Hello from LocalStack! Hi API Force audience!")

    list_buckets()

    return {"hello": "world"}


def list_buckets():
    import boto3
    client = boto3.client("s3")
    result = client.list_buckets()["Buckets"]
    print("Existing buckets:", result)
