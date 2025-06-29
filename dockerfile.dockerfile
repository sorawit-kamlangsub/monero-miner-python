FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    python3-dev \
    libssl-dev \
    libffi-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel
RUN python -m pip install --upgrade pip setuptools wheel

# DEBUG: Install pyrx with verbose to see the real cause of error
RUN pip install py-cryptonight && \
    pip install --verbose git+https://github.com/jtgrassie/pyrx.git#egg=pyrx

# Add your files
WORKDIR /app
COPY moneropoolwork.py .
COPY job.json .

# Run the miner
ENTRYPOINT ["python", "moneropoolwork.py", "job.json"]
