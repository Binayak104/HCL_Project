# Stage 1: Build Stage (Debian-based for modern GCC/Tools)
FROM python:3.11-bookworm as builder

# Install system build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY requirements.txt .

# Install python dependencies to a local directory
RUN pip install --upgrade pip wheel setuptools
# Force binary install to avoid source compilation
RUN pip install --no-cache-dir --target /build/package --only-binary=:all: -r requirements.txt

# Stage 2: Runtime Stage (AWS Lambda Node)
FROM public.ecr.aws/lambda/python:3.11

# Copy installed packages from builder
COPY --from=builder /build/package ${LAMBDA_TASK_ROOT}

# Copy application code
COPY . ${LAMBDA_TASK_ROOT}/backend

CMD [ "backend.main.handler" ]
