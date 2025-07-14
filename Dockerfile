# Build stage
FROM python:3.10-slim AS build

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        git build-essential cmake python3-dev \
        libssl-dev libffi-dev pkg-config ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel

RUN pip install --no-cache-dir py-cryptonight

WORKDIR /opt
RUN git clone --depth 1 --recursive https://github.com/jtgrassie/pyrx.git
RUN pip install --no-cache-dir /opt/pyrx

# Runtime stage
FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Correct package path copy for Python 3.10
COPY --from=build /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=build /usr/local/bin /usr/local/bin

WORKDIR /app
COPY moneropoolwork.py .
COPY job.json .

ENTRYPOINT ["python", "moneropoolwork.py", "job.json"]
