# Project Issues & Solutions Log

## 1. Backend 500 Error (ImportModuleError)
**Problem:** The initial Lambda deployment failed with `Runtime.ImportModuleError: Unable to import module 'main'`. This was caused by the `chromadb` library requiring `sqlite3` >= 3.35, but the AWS Lambda Python runtime uses an older version.
**Solution:** 
- Switched the Backend Dockerfile to use `public.ecr.aws/lambda/python:3.11` (based on Amazon Linux 2023) which usually has newer libraries.
- Explicitly installed `pysqlite3-binary` and overrode the system `sqlite3` module in `main.py`:
  ```python
  __import__('pysqlite3')
  import sys
  sys.modules['sqlite3'] = sys.modules.pop('pysqlite3')
  ```

## 2. Infrastructure: Missing Internet Gateway
**Problem:** The EC2 instance hosting ChromaDB could not pull Docker images because it was in a public subnet that lacked an Internet Gateway and Route Table.
**Solution:** 
- Added `aws_internet_gateway` and `aws_route_table` resources to `infrastructure/layer1/main.tf`.
- Associated the subnet with this route table to allow outbound internet access.

## 3. ChromaDB Connection Refused
**Problem:** The Backend (Lambda) could not connect to ChromaDB on the EC2 instance (`ConnectionRefusedError`).
**Causes:**
1.  Security Group didn't allow inbound traffic on port 8000.
2.  The Lambda function was using a "Stale" IP address after the EC2 instance was replaced.
**Solution:**
- Updated Security Group to allow Inbound TCP on Port 8000 from `0.0.0.0/0` (for development).
- Forced Terraform to update the Lambda configuration with the new EC2 Public IP by using a `terraform taint` on the Lambda function or updating a dummy environment variable.

## 4. ChromaDB Version Mismatch (HTTP 410 Gone)
**Problem:** The Backend threw `410 Client Error: Gone` when trying to talk to ChromaDB.
**Cause:** The `chromadb` client library version in `requirements.txt` (latest, `0.6.0`) was incompatible with the older ChromaDB server version running on EC2.
**Solution:**
- Pinned both the Server (in EC2 User Data) and the Client (in `backend/requirements.txt`) to version **`0.5.20`**.

## 5. Lambda Timeouts
**Problem:** The API Gateway returned `504 Gateway Timeout`.
**Cause:** The default Lambda timeout is 3 seconds, which is too short for AI inference (Bedrock) and Database operations.
**Solution:**
- Increased `timeout` to **60 seconds** in `infrastructure/layer2/main.tf`.

## 6. Frontend "Localhost" Error
**Problem:** The deployed Frontend (App Runner) tried to connect to `http://localhost:8000` instead of the AWS API Gateway.
**Cause:** Next.js uses build-time environment variables. The `NEXT_PUBLIC_API_URL` variable was not properly baked in during the Docker build process or was defaulting to localhost.
**Solution:**
- Temporarily **hardcoded** the production API Gateway URL in `frontend/lib/api.ts`.
- Forced a redeployment of the App Runner service to pick up the change.
