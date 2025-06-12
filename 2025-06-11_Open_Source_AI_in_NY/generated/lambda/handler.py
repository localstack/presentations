import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info('Received S3 event: %s', json.dumps(event))
    
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        event_name = record['eventName']
        
        logger.info(f'Processed {event_name} event for s3://{bucket}/{key}')
    
    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed S3 event')
    } 