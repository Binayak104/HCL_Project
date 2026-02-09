import boto3
import sys

log_group = '/aws/lambda/hcl-project-api'

client = boto3.client('logs', region_name='us-east-1')

try:
    # Get latest log stream
    streams = client.describe_log_streams(
        logGroupName=log_group,
        orderBy='LastEventTime',
        descending=True,
        limit=1
    )
    
    if not streams['logStreams']:
        print("No log streams found.")
        sys.exit(0)
        
    stream_name = streams['logStreams'][0]['logStreamName']
    print(f"Fetching logs from: {stream_name}")

    response = client.get_log_events(
        logGroupName=log_group,
        logStreamName=stream_name,
        limit=50,
        startFromHead=False
    )

    print("--- LOG EVENTS ---")
    for event in response['events']:
        print(event['message'].strip())
    print("--- END LOGS ---")

except Exception as e:
    print(f"Error: {e}")
