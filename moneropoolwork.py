import json
import time
import struct
import binascii
import pycryptonight
import pyrx
import sys
import os

nicehash = False  # set True if testing nicehash jobs

def pack_nonce(blob, nonce):
    b = binascii.unhexlify(blob)
    bin_data = struct.pack('39B', *bytearray(b[:39]))
    if nicehash:
        bin_data += struct.pack('I', nonce & 0x00ffffff)[:3]
        bin_data += struct.pack(f'{len(b)-42}B', *bytearray(b[42:]))
    else:
        bin_data += struct.pack('I', nonce)
        bin_data += struct.pack(f'{len(b)-43}B', *bytearray(b[43:]))
    return bin_data


def main():
    with open('job.json', 'r') as f:
        job = json.load(f)

    blob = job['blob']
    target_hex = job['target']
    job_id = job.get('job_id', '')
    height = job.get('height', 0)
    seed_hash = job.get('seed_hash', '')

    block_major = int(blob[:2], 16)
    cnv = block_major - 6 if block_major >= 7 else 0

    print(f"🔧 Starting job: height={height}, target={target_hex}, cn_variant={cnv}")

    target = struct.unpack('I', binascii.unhexlify(target_hex))[0]
    if target >> 32 == 0:
        target = int(0xFFFFFFFFFFFFFFFF / int(0xFFFFFFFF / target))

    seed_bin = binascii.unhexlify(seed_hash) if cnv > 5 else None
    nonce = 0
    hash_count = 0
    start_time = time.time()

    while True:
        bin_blob = pack_nonce(blob, nonce)
        if cnv > 5:
            hash_result = pyrx.get_rx_hash(bin_blob, seed_bin, height)
        else:
            hash_result = pycryptonight.cn_slow_hash(bin_blob, cnv, 0, height)

        hash_count += 1
        r64 = struct.unpack('Q', hash_result[24:])[0]
        hex_hash = binascii.hexlify(hash_result).decode()
        if r64 < target:
            elapsed = time.time() - start_time
            hps = int(hash_count / elapsed)
            print(f"\n✅ Valid nonce found: {nonce}")
            print(f"Hash: {hex_hash}")
            print(f"Hashrate: {hps} H/s")
            print(f"Result: {{'job_id': '{job_id}', 'nonce': {nonce}, 'result': '{hex_hash}'}}")
            break

        if nonce % 10000 == 0:
            sys.stdout.write(f"\r⛏️ Nonce: {nonce} / Hashes: {hash_count}")
            sys.stdout.flush()

        nonce += 1


if __name__ == '__main__':
    main()
