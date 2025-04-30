#!/bin/bash
# script to automate CSRF token extraction and brute-forcing
# obviously, change the URL and wordlist to your needs

bash CSRFbypass.bash \
    'https://example.com/login?username=admin&password=HIT' \
    wordlist.txt
exit 0

# This script might not work for all websites, as CSRF tokens can be implemented in various ways.
# In the future, I will add more CSRF token extraction methods.
# This script is for educational purposes only. Use it at your own risk.
# I might make python versions of all curlBrute scripts in the future.
# I might make curlBrute a full-fledged tool in the future. banners, help, error handling, etc.
# Right now, this is just a proof of concept kinda thingy.
# Happy hacking.