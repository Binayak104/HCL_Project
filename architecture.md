# HCL Engagement Assessment - Technical Architecture

This document provides a comprehensive overview of the **HMRC Engagement Assessment** application, covering its architecture, project structure, deployment workflow, and key technical challenges encountered during development.

## 1. High-Level Architecture

The application is built using a cloud-native, serverless-first approach on AWS to ensure scalability and cost-efficiency.

```mermaid
graph TD
    User[User Browser] -->|HTTPS| Frontend[Frontend (AWS App Runner)]
    Frontend -->|API Calls (Next.js)| APIGw[API Gateway HTTP API]
    APIGw -->|Proxy Integration| Lambda[Backend (AWS Lambda)]
    Lambda -->|SQL + Vector (TCP/5432)| RDS[Vector Layer (RDS PostgreSQL)]
    Lambda -->|GenAI (Boto3)| Bedrock[AWS Bedrock]
    RDS -.->|Depends On| L1[Layer 1 (Network)]
    Lambda -.->|Depends On| RDS
    Lambda -.->|Depends On| L1
```

### Deployment Layers
1.  **Layer 1 (Base)**: VPC, Subnets, Internet Gateway, and ECR Repositories.
2.  **Vector Layer**: RDS PostgreSQL with the `pgvector` extension. (Depends on Layer 1).
3.  **Layer 2 (App)**: Lambda (Backend) and App Runner (Frontend). (Depends on Layer 1 and Vector Layer).

---

## 2. Project Structure & File Explanation

```
HCL_Project/
├── backend/                  # FastAPI Application
│   ├── api/                  # Route handlers (assessment.py, health.py)
│   ├── services/             # Business logic (bedrock_service.py, pgvector_service.py)
│   ├── models/               # Pydantic data models
│   ├── Dockerfile            # Instructions to build Lambda-compatible container
│   ├── requirements.txt      # Python dependencies (fastapi, psycopg2, pgvector)
│   └── main.py               # Application entry point
│
├── frontend/                 # Next.js Application
│   ├── app/                  # Next.js App Router pages
│   ├── components/           # Reusable UI components (Forms, Cards)
│   ├── lib/                  # Utilities (API client)
│   ├── Dockerfile            # Multistage build for Next.js standalone output
│   └── next.config.ts        # Configured for 'output: standalone'
│
├── infrastructure/           # Terraform (IaC)
│   ├── modules/              # Reusable modules (layer1, vector, layer2)
│   ├── layer1/               # Base Networking & ECR
│   ├── vector/               # RDS PostgreSQL (pgvector)
│   └── layer2/               # App Runner & Lambda
│
└── .github/workflows/        # Manual CI/CD Pipelines
    ├── infra-layer1.yml      # Deploy/Destroy Layer 1
    ├── infra-vector.yml      # Deploy/Destroy Vector Layer
    ├── infra-layer2.yml      # Deploy/Destroy Layer 2
    ├── backend.yml           # Manual Deploy/Destroy Backend Code
    └── frontend.yml          # Manual Deploy/Destroy Frontend Code
```

---

## 3. Deployment Workflow

The project uses a **Decoupled Deployment Strategy**:

1.  **Infrastructure Provisioning (Terraform)**:
    *   Sets up the "skeleton" of the app: Networking (VPC), Compute (Lambda/App Runner), and Permissions (IAM).
    *   *Challenge*: It needs the Docker images to already exist in ECR to create the Lambda/App Runner services.

2.  **Application Delivery (GitHub Actions)**:
    *   **Backend Workflow**: Changes to `backend/` trigger a build. The image is pushed to ECR with the `latest` tag. Then, it explicitly tells Lambda to update its code.
    *   **Frontend Workflow**: Changes to `frontend/` trigger a build. The image is pushed to ECR. App Runner (configured with auto-deploy) picks up the new image.

---

## 4. Technical Challenges & Solutions

### A. The "Chicken and Egg" Problem
**Issue**: Terraform attempts to create the Lambda function and App Runner service. These resources **require a container image** URL (e.g., `.../repo:latest`) to exist. However, the CI/CD pipeline usually builds the image *after* the infrastructure is ready.
**Result**: The first deployment often fails with "Manifest Unknown" or "Image not found".
**Solution**:
1.  **Allow Failure**: Let Terraform create the ECR repositories (but fail on Lambda/App Runner creation).
2.  **Push Images**: Manually trigger the "Deploy Backend" and "Deploy Frontend" workflows to populate the ECR repos.
3.  **Re-run Terraform**: Now that images exist, Terraform can successfully creating the computing resources.

### B. VPC & Subnet Issues
**Issue**: The default `main.tf` relied on the "Default VPC" existing in the AWS account. In some regions or older accounts, the Default VPC might not have subnets in all Availability Zones, or might be missing entirely.
**Error**: `subnet_id: empty list of string`.
**Solution**:
1.  Updated `main.tf` to create a **Dedicated VPC** (`aws_vpc`) and a **Public Subnet** (`aws_subnet`) explicitly for this project.
2.  Ensured the EC2 instance and Security Groups are attached to this new, reliable network.

### C. Node.js Version Mismatch
**Issue**: Next.js 14 requires Node.js 18.17+ or 20+. The original Dockerfile used an older Alpine base image.
**Error**: `You are using Node.js 18.x. For Next.js, Node.js version >=20.9.0 is required.`
**Solution**:
1.  Updated `frontend/Dockerfile` to use `FROM node:20-alpine`.

### D. ChromaDB Compilation on Lambda
**Issue**: The standard `chromadb` Python package attempts to compile native C++ dependencies (like `hnswlib`). AWS Lambda's environment is stripped down and lacks the necessary compilers (`gcc`, `c++`), causing build failures.
**Error**: `pip install` fails with "Encountered error while generating package metadata".
**Solution**:
1.  **Switch to `chromadb-client`**: Since the Backend only connects to an *external* ChromaDB server (on EC2), it doesn't need the full core engine. The `chromadb-client` package is lightweight, pure Python, and works perfectly on Lambda without compilation.

---

## 5. How to Destroy
To avoid ongoing costs, destroy the infrastructure:
1.  Go to GitHub Actions -> **Terraform Destroy**.
2.  Run the workflow for `prod`.
3.  **Verify**: Check AWS Console (App Runner, Lambda, EC2) to ensure resources are gone.
