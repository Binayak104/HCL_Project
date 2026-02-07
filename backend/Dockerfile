FROM public.ecr.aws/lambda/python:3.11

# Install build dependencies
RUN yum install -y gcc-c++ make

COPY requirements.txt ${LAMBDA_TASK_ROOT}

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . ${LAMBDA_TASK_ROOT}/backend

CMD [ "backend.main.handler" ]
