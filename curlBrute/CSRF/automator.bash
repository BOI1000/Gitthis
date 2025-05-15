#!/bin/bash
# script to automate CSRF token extraction and brute-forcing
# obviously, change the URL and wordlist to your needs

bash CSRFbypass.bash \
    'https://example.com/login?username=admin&password=HIT' \
    '/usr/share/wordlists/rockyou.txt'
exit 0

# This script might not work for all websites, as CSRF tokens can be implemented in various ways.
# In the future, I will add more CSRF token extraction methods.
# ^ based on what ever i run into