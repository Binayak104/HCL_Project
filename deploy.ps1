# Deploy Infrastructure and Apps
# Prerequisites: AWS CLI configured, Docker running, Terraform installed

# 1. Bootstrap Remote State (Run ONCE manually usually, but here for reference)
# cd infrastructure/bootstrap
# terraform init
# terraform apply -auto-approve
# $STATE_BUCKET=$(terraform output -raw state_bucket_name)
# Write-Host "State Bucket: $STATE_BUCKET"
# cd ../..

# NOTE: You MUST update infrastructure/main.tf with the actual bucket name from step 1 before running step 2.

# 2. Deploy Main Infrastructure
cd infrastructure
terraform init
# For the first run, we target ECR to build images
terraform apply -target=aws_ecr_repository.backend -target=aws_ecr_repository.frontend -auto-approve

# Get Repo URLs
$BACKEND_REPO = $(terraform output -raw backend_repo_url)
$FRONTEND_REPO = $(terraform output -raw frontend_repo_url)
cd ..

# 3. Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $BACKEND_REPO

# 4. Build and Push Backend
docker build -t $BACKEND_REPO:latest ./backend
docker push $BACKEND_REPO:latest

# 5. Build and Push Frontend
docker build -t $FRONTEND_REPO:latest ./frontend
docker push $FRONTEND_REPO:latest

# 6. Full Deploy
cd infrastructure
terraform apply -auto-approve
