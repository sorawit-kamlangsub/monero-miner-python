# monero-miner-python
sudo docker build -t monero-miner-python .

sudo docker run -v $(pwd):/app -w /app monero-miner-python job.json
