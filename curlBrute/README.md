# This script was used in a CTF challenge! 
Here's what I recommend to do before using it for brute forcing:
- 1. Make sure you have permission to brute force the target. # this is AI generated
- 2. Use `cewl` to generate a wordlist from the target site and use that wordlist for the attack first.
```bash
cewl -w wordlist.txt -d 2 -m 5 -c 5 https://example.com/path/to/dir
```
- 3. Use the wordlist to brute force the target.
```bash
./curlBrute.bash "https://example.com/login.php?username=admin&password=HIT" /path/to/cewl/wordlist # or you can use your CurlBrutePayload
```
- 4. Look for HTTP status code 302, as it may indicate a successful attempt. This was key in my CTF challenge.