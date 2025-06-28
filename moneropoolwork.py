import struct
import json
import sys

import pyrx

def compact_to_target(compact):
    n = int.from_bytes(bytes.fromhex(compact), 'little')
    exponent = n >> 24
    mantissa = n & 0xFFFFFF

    if exponent <= 3:
        target = mantissa >> (8 * (3 - exponent))
    else:
        target = mantissa << (8 * (exponent - 3))

    return target

def main():
    if len(sys.argv) < 2:
        print("Usage: python miner.py job.json")
        sys.exit(1)
    
    job_file = sys.argv[1]

    with open(job_file, "r") as f:
        job = json.load(f)

    blob_hex = job["blob"]
    target_hex = job["target"]
    seed_hash = job["seed_hash"]

    target = compact_to_target(target_hex)
    blob = bytearray.fromhex(blob_hex)
    nonce_offset = 39

    rx = pyrx.Randomx(seed_hash)

    print(f"Mining block height {job.get('height')}...")

    for nonce in range(1_000_000):
        blob[nonce_offset:nonce_offset+4] = struct.pack('<I', nonce)
        h = rx.hash(blob)
        hash_int = int.from_bytes(h, 'little')
        if hash_int < target:
            print(f"Valid nonce found: {nonce}")
            print(f"Hash: {h.hex()}")
            return

    print("No valid nonce found in range.")

if __name__ == "__main__":
    main()
