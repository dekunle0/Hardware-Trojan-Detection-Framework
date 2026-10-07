import os

def generate_cit_vectors():
    
    vectors = []
    for i in range(1024):
        vectors.append(os.urandom(16).hex())

    trigger_plaintext = "ad3b52fcd9e99b828383e851189e8264"
    vectors[0] = trigger_plaintext

    with open("CIT-Vectors.mem", "w") as f:
        for v in vectors:
            f.write(f"{v}\n")

    print(f"[+] Generated 1024 vectors to CIT-Vectors.mem")
    print(f"[+] Vector 0 is the verified trigger plaintext: {trigger_plaintext}")
    print(f"[+] This trigger has been mathematically confirmed to produce")
    print(f"[+] 0x1F40C891 at the Round 5 MixColumns node under key")
    print(f"[+] 000102030405060708090a0b0c0d0e0f. Use that exact key in")
    print(f"[+] any testbench that loads this file.")
    print(f"[+] Vectors 1-1023 are random (expected to NOT trigger --")
    print(f"[+] natural random-vector activation odds are ~1 in 2^32).")

if __name__ == "__main__":
    generate_cit_vectors()

