import struct
import json
import sys
import randomx

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
        print("Usage: python moneropoolwork.py job.json")
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

    print(f"Mining block height {job.get('height')}...")

    flags = randomx.Flag.DEFAULT
    cache = randomx.Cache(flags, bytes.fromhex(seed_hash))
    vm = randomx.VirtualMachine(flags, cache)

    for nonce in range(1_000_000):
        blob[nonce_offset:nonce_offset+4] = struct.pack('<I', nonce)
        h = vm.calculate_hash(blob)
        hash_int = int.from_bytes(h, 'little')
        if hash_int < target:
            print(f"✅ Valid nonce: {nonce}")
            print(f"Hash: {h.hex()}")
            return

    print("❌ No valid nonce found.")

if __name__ == "__main__":
    main()
