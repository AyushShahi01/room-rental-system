import os
import sys
import django
import requests

# Set up Django environment
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
django.setup()

from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from django.conf import settings
import boto3
from botocore.exceptions import NoCredentialsError, ClientError

def test_django_storage_configuration():
    print("=== 1. Django Storage Configuration ===")
    
    # Print settings values (hiding secret keys)
    print(f"B2_BUCKET_NAME: {settings.B2_BUCKET_NAME}")
    print(f"B2_ENDPOINT_URL: {settings.B2_ENDPOINT_URL}")
    print(f"B2_REGION: {settings.B2_REGION}")
    print(f"B2_KEY_ID: {settings.B2_KEY_ID[:5]}... (length: {len(settings.B2_KEY_ID) if settings.B2_KEY_ID else 0})")
    
    # Check default storage class
    storage_class = default_storage.__class__.__name__
    print(f"Active default_storage class: {storage_class}")
    
    if storage_class == 'S3Storage':
        print("[SUCCESS] Django is configured to use S3/B2 storage as default.")
    else:
        print("[WARNING] Django is NOT using S3/B2 storage as default (using local storage).")

def test_raw_boto3_connectivity():
    print("\n=== 2. Raw boto3 Client Connectivity ===")
    
    if not all([settings.B2_KEY_ID, settings.B2_APPLICATION_KEY, settings.B2_ENDPOINT_URL]):
        print("[SKIP] Missing B2 settings. Cannot test boto3 connectivity.")
        return False
        
    s3_client = boto3.client(
        's3',
        aws_access_key_id=settings.B2_KEY_ID,
        aws_secret_access_key=settings.B2_APPLICATION_KEY,
        endpoint_url=settings.B2_ENDPOINT_URL,
        region_name=settings.B2_REGION
    )
    
    # 1. Test Listing Buckets (frequently restricted for application keys)
    try:
        print("Attempting to list all buckets in the account...")
        response = s3_client.list_buckets()
        buckets = [b['Name'] for b in response.get('Buckets', [])]
        print(f"[SUCCESS] Available buckets: {buckets}")
    except ClientError as e:
        if e.response['Error']['Code'] == 'AccessDenied':
            print("[INFO] list_buckets() access denied (AccessDenied: not entitled). This is normal for bucket-restricted application keys.")
        else:
            print(f"[WARNING] list_buckets() failed with: {e}")
            
    # 2. Test direct access to the specific bucket (list objects)
    try:
        print(f"Directly listing objects in configured bucket '{settings.B2_BUCKET_NAME}'...")
        objects_resp = s3_client.list_objects_v2(Bucket=settings.B2_BUCKET_NAME, MaxKeys=5)
        contents = objects_resp.get('Contents', [])
        print(f"[SUCCESS] Connected to bucket '{settings.B2_BUCKET_NAME}'. Found {len(contents)} objects (showing first 5):")
        for obj in contents:
            print(f" - {obj['Key']} ({obj['Size']} bytes)")
        return True
    except Exception as e:
        print(f"[FAILURE] Direct bucket access failed for '{settings.B2_BUCKET_NAME}': {e}")
        return False

def test_file_operations():
    print("\n=== 3. Django Storage File Operations ===")
    
    test_filename = "test_storage_dummy.txt"
    test_content = b"Hello Backblaze B2! This is a test file created by room-rental-system testing script."
    
    try:
        # 1. Clean up if file already exists
        if default_storage.exists(test_filename):
            print(f"Test file '{test_filename}' already exists. Deleting it first...")
            default_storage.delete(test_filename)
            
        # 2. Save file
        print(f"Saving test file '{test_filename}'...")
        saved_name = default_storage.save(test_filename, ContentFile(test_content))
        print(f"Saved as: {saved_name}")
        
        # 3. Check existence
        exists = default_storage.exists(test_filename)
        print(f"File exists in storage: {exists}")
        if not exists:
            print("[FAILURE] File was saved but exists() returned False.")
            return
            
        # 4. Get unsigned URL (configured default)
        unsigned_url = default_storage.url(test_filename)
        print(f"Generated Unsigned URL: {unsigned_url}")
        
        # 5. Get signed URL (for comparison, using boto3)
        s3_client = boto3.client(
            's3',
            aws_access_key_id=settings.B2_KEY_ID,
            aws_secret_access_key=settings.B2_APPLICATION_KEY,
            endpoint_url=settings.B2_ENDPOINT_URL,
            region_name=settings.B2_REGION
        )
        # S3 Storage is configured under settings.AWS_LOCATION (usually 'media')
        s3_key = f"{settings.AWS_LOCATION}/{test_filename}" if hasattr(settings, 'AWS_LOCATION') else test_filename
        signed_url = s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': settings.B2_BUCKET_NAME, 'Key': s3_key},
            ExpiresIn=3600
        )
        print(f"Generated Signed URL: {signed_url}")
        
        # 6. Read file back through default_storage
        print("Reading file contents back via storage client...")
        with default_storage.open(test_filename, 'rb') as f:
            read_content = f.read()
        print(f"Read content: {read_content}")
        
        if read_content == test_content:
            print("[SUCCESS] Content read back matches original content.")
        else:
            print(f"[FAILURE] Content mismatch. Expected {test_content}, got {read_content}")
            
        # 7. Test public HTTP access to unsigned URL
        print("\nTesting Unsigned URL readability over HTTP...")
        try:
            http_resp = requests.get(unsigned_url, timeout=10)
            print(f"Unsigned URL HTTP Status Code: {http_resp.status_code}")
            if http_resp.status_code == 200:
                print("[SUCCESS] Bucket is PUBLIC: Unsigned URL is readable.")
            elif http_resp.status_code == 401 or http_resp.status_code == 403:
                print("[INFO] Bucket is PRIVATE: Unsigned URL requires authentication (returned 401/403).")
            else:
                print(f"[WARNING] Unsigned URL returned unexpected status code: {http_resp.status_code}")
        except Exception as http_err:
            print(f"[WARNING] Failed to fetch unsigned URL: {http_err}")
            
        # 8. Test HTTP access to signed URL
        print("\nTesting Signed URL readability over HTTP...")
        try:
            http_resp = requests.get(signed_url, timeout=10)
            print(f"Signed URL HTTP Status Code: {http_resp.status_code}")
            if http_resp.status_code == 200:
                print("[SUCCESS] Signed URL is readable!")
                print(f"Signed URL content matches: {http_resp.content == test_content}")
            else:
                print(f"[FAILURE] Signed URL returned status code: {http_resp.status_code}")
                print(f"Response: {http_resp.text[:200]}")
        except Exception as http_err:
            print(f"[FAILURE] Failed to fetch signed URL: {http_err}")
            
        # 9. Delete file
        print(f"\nCleaning up: deleting '{test_filename}'...")
        default_storage.delete(test_filename)
        still_exists = default_storage.exists(test_filename)
        print(f"File exists after deletion: {still_exists}")
        if not still_exists:
            print("[SUCCESS] Test file cleaned up successfully.")
        else:
            print("[FAILURE] Test file still exists after deletion attempt.")
            
    except Exception as e:
        print(f"[FAILURE] File operations failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    print("Starting Object Storage Diagnostic Tests...")
    test_django_storage_configuration()
    test_raw_boto3_connectivity()
    test_file_operations()
    print("\nDiagnostics complete.")
