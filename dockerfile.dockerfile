FROM python:3.11-slim

# Install build tools and system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        cmake \
        python3-dev \
        libssl-dev \
        libffi-dev \
        && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install dependencies
RUN pip install py-cryptonight \
    && pip install git+https://github.com/jtgrassie/pyrx.git#egg=pyrx

# Set working directory
WORKDIR /app

# Copy code
COPY moneropoolwork.py .
COPY job.json .

# Run the miner
ENTRYPOINT ["python", "moneropoolwork.py", "job.json"]
