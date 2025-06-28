FROM python:3.11-slim

RUN apt-get update && apt-get install -y build-essential git python3-dev && rm -rf /var/lib/apt/lists/*

RUN pip install pyrx

WORKDIR /app
COPY moneropoolwork.py .

ENTRYPOINT ["python", "moneropoolwork.py"]
