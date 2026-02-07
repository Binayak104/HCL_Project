FROM public.ecr.aws/lambda/python:3.11

# Install build dependencies
RUN yum install -y gcc-c++ make python3-devel

COPY requirements.txt ${LAMBDA_TASK_ROOT}

RUN pip install --upgrade pip setuptools wheel
RUN pip install "numpy<2.0" --only-binary=:all:
RUN pip install -r requirements.txt

COPY . ${LAMBDA_TASK_ROOT}/backend

CMD [ "backend.main.handler" ]
