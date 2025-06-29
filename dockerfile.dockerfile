FROM python:3.11-slim

# Set environment to prevent Python from writing .pyc files and using buffered output
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install dependencies for building pyrx
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    python3-dev \
    libssl-dev \
    libffi-dev \
    ca-certificates \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and essential Python packaging tools
RUN python3 -m pip install --upgrade pip setuptools wheel

# DEBUG: Install pyrx with full verbose output
RUN pip install --verbose py-cryptonight && \
    pip install --verbose --no-cache-dir git+https://github.com/jtgrassie/pyrx.git#egg=pyrx

# Set working directory
WORKDIR /app

# Copy application code
COPY moneropoolwork.py .
COPY job.json .

# Define default command
ENTRYPOINT ["python", "moneropoolwork.py", "job.json"]
