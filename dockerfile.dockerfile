FROM python:3.11-slim

# Install system build tools
RUN apt-get update && \
    apt-get install -y git build-essential cmake python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Install py-randomx (from source)
RUN pip install py-cryptonight && pip install git+https://github.com/jtgrassie/pyrx.git#egg=pyrx

WORKDIR /app
COPY moneropoolwork.py .
COPY job.json .

ENTRYPOINT ["python", "moneropoolwork.py", "job.json"]
