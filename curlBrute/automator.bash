#!/bin/bash
# If anyone were to use the curlBrute script in a bash shell, I recommend using this format to execute it:

 bash curlBrute.bash \
    "https://example.com/login.php?username=admin&password=HIT" \
    "/usr/share/wordlists/rockyou.txt"
exit 0 

# The purpose of THIS script is to automate this process and make it easier to use.
# change this to your own URL and wordlist
# put the HIT where you want to brute force