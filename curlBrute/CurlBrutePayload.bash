#!/bin/bash
# If anyone were to use the curlBrute script in a bash shell, I recommend making a script like this or using back-slashes to execute this script.
# For example:
# ./curlBrute.bash \ 
# "https://example.com/login.php?username=admin&password=HIT" \
# /usr/share/wordlists/rockyou.txt
# The purpose of THIS script is to automate this process and make it easier to use.

./curlBrute.bash \
"https://example.com/login.php?username=admin&password=HIT" \
"/usr/share/wordlists/rockyou.txt"
exit 0 

# change this to your own URL and wordlist
# put the HIT where you want to brute force
# IMPORTANT: If you are not familiar with status codes, you should know that 200 is a success and 403 is a forbidden error.
# 404 is a not found error. 500 is a server error. 301 is a redirect. 302 is a temporary redirect.
# In the future, The target status code for a successful HIT will be 302 and 200 will be the curl -L doing its job.
# The reason why the HIT success code will be 302 is because the target will usually be a login page and the 302 will redirect to the dashboard (usually).