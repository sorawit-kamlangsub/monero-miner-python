# ────────────────────────────────────────────────────────────────────────────────
# Stage 1 – build everything we need
# ────────────────────────────────────────────────────────────────────────────────
FROM python:3.11-slim AS build

# Avoid .pyc files and use unbuffered stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# — System‑level build tools and libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
        git build-essential cmake python3-dev \
        libssl-dev libffi-dev pkg-config ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# — Latest Python packaging tools
RUN python -m pip install --upgrade pip setuptools wheel

# ────────────────────────────────────────────────────────────────────────────────
# Python dependencies
# ────────────────────────────────────────────────────────────────────────────────
# 1) Pure‑pip package
RUN pip install --no-cache-dir py-cryptonight

# 2) pyrx – clone WITH sub‑modules, then install from local path
WORKDIR /opt
RUN git clone --depth 1 --recursive https://github.com/jtgrassie/pyrx.git
RUN pip install --no-cache-dir /opt/pyrx

# ────────────────────────────────────────────────────────────────────────────────
# Stage 2 – runtime‑only image (smaller)
# ────────────────────────────────────────────────────────────────────────────────
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copy installed site‑packages and entry points from the build stage
COPY --from=build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=build /usr/local/bin /usr/local/bin

# Your application code
WORKDIR /app
COPY moneropoolwork.py .
COPY job.json .

ENTRYPOINT ["python", "moneropoolwork.py", "job.json"]
