import boto3
import sys

def empty_and_delete_bucket(bucket_name):
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)

    try:
        print(f"Emptying bucket: {bucket_name}")
        bucket.object_versions.delete()
        print(f"Deleting bucket: {bucket_name}")
        bucket.delete()
        print(f"Bucket {bucket_name} deleted.")
    except Exception as e:
        print(f"Error handling bucket {bucket_name}: {e}")

def delete_dynamodb_table(table_name):
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table(table_name)

    try:
        print(f"Deleting table: {table_name}")
        table.delete()
        print(f"Table {table_name} deletion initiated.")
        table.wait_until_not_exists()
        print(f"Table {table_name} deleted.")
    except Exception as e:
        if "ResourceNotFoundException" in str(e):
             print(f"Table {table_name} already deleted.")
        else:
            print(f"Error deleting table {table_name}: {e}")

if __name__ == "__main__":
    bucket_name = "hcl-project-tf-state-20260209130725265000000001"
    table_name = "hcl-project-tf-locks"
    
    empty_and_delete_bucket(bucket_name)
    delete_dynamodb_table(table_name)
