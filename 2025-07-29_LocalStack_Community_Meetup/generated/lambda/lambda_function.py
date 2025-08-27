import json
import requests
from datetime import datetime

def handler(event, context):
    print("Received event:", json.dumps(event))
    for record in event.get('Records', []):
        s3_info = record.get('s3', {})
        bucket = s3_info.get('bucket', {}).get('name')
        obj = s3_info.get('object', {})
        file_name = obj.get('key')
        size = obj.get('size', 0)
        timestamp = record.get('eventTime', datetime.utcnow().isoformat())
        payload = {
            'file_name': file_name,
            'size': size,
            'timestamp': timestamp
        }
        try:
            resp = requests.post(
                'http://host.docker.internal:8080/add_upload',
                json=payload,
                timeout=5
            )
            print(f"POST /add_upload response: {resp.status_code} {resp.text}")
        except Exception as e:
            print(f"Error calling Flask API: {e}")
    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    } 