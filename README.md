# HCL Engagement Assessment Project

A Full-Stack Application for HMRC Engagement Assessment.

## Architecture
- **Frontend**: Next.js (React) deployed on AWS App Runner.
- **Backend**: FastAPI (Python) deployed on AWS Lambda via API Gateway.
- **Data Layer**:
  - **ChromaDB**: Hosted on AWS EC2 (Instance with Docker).
  - **Storage**: AWS S3 for documents and logs.
- **AI**: AWS Bedrock (Nova Model) for risk assessment.

## Repository Structure
- `frontend/`: Next.js application source code.
- `backend/`: FastAPI application source code and services.
- `infrastructure/`: Terraform configuration for AWS resources.
- `docker/`: Local development utilities.
- `.github/workflows/`: CI/CD pipelines for deployment.

## Deployment
This project uses **Terraform** for Infrastructure as Code and **GitHub Actions** for CI/CD.

### Prerequisites
1.  **AWS Account**: Credentials with appropriate permissions.
2.  **Terraform**: Installed locally for bootstrap.
3.  **GitHub Secrets**:
    - `AWS_ACCESS_KEY_ID`
    - `AWS_SECRET_ACCESS_KEY`
    - `SSH_KEY` (Optional, for EC2 access)

### Setup
1.  **Bootstrap Remote State**:
    Run Terraform in `infrastructure/bootstrap/` to create the S3 bucket for state storage.
    Update `infrastructure/main.tf` with the generated bucket name.

2.  **Push to GitHub**:
    Pushing to the `main` branch triggers the deployment pipeline.
    - `backend.yml`: Deploys Backend to Lambda.
    - `frontend.yml`: Deploys Frontend to App Runner.
    - `terraform.yml`: Applies infrastructure changes.

## Local Development
- **Backend**: `cd backend && uvicorn main:app --reload`
- **Frontend**: `cd frontend && npm run dev`
