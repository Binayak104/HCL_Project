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
    # --- Remote State Configuration ---
    BUCKET_NAME = "hcl-project-tf-state-20260219115130774700000001"
    DYNAMODB_TABLE = "hcl-project-tf-locks"
    REGION = "us-east-1"
    
    empty_and_delete_bucket(BUCKET_NAME)
    delete_dynamodb_table(DYNAMODB_TABLE)
