# Stage 1: Build Stage (Amazon Linux 2 based for Lambda compatibility)
FROM public.ecr.aws/lambda/python:3.11 as builder

# Install system build dependencies (yum for Amazon Linux)
RUN yum update -y && yum install -y \
    gcc \
    gcc-c++ \
    make \
    cmake \
    && yum clean all

WORKDIR /build

COPY requirements.txt .

# Install python dependencies to a local directory
RUN pip install --upgrade pip wheel setuptools
# Allow binary or source install, pip will pick compatible wheels for AL2
RUN pip install --no-cache-dir --target /build/package -r requirements.txt

# Stage 2: Runtime Stage (AWS Lambda Node)
FROM public.ecr.aws/lambda/python:3.11

# Copy installed packages from builder
COPY --from=builder /build/package ${LAMBDA_TASK_ROOT}

# Copy application code - ensure correct directory structure
# Copying current directory to ${LAMBDA_TASK_ROOT}/backend means imports will be backend.api...
COPY . ${LAMBDA_TASK_ROOT}/backend

CMD [ "backend.main.handler" ]
