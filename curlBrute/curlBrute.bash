#!/bin/bash
function brutus_one() {
    local url="$1"
    local data="$2"
    local file="$3"
    while read -r line; do
        if echo "$data" | grep -q "HIT"; then
            hitter=$(echo "$data" | sed "s/HIT/$line/g" 2>/dev/null)
        fi
        echo "$hitter" # for debugging
        agents=("Mozila/5.0" "Chrome/100.0" "Safari/537.36" "Opera/9.80" "Edge/18.18362")
        ua=${agents[RANDOM % ${#agents[@]}]}
        curl -v -L \
            -A "$ua" \
            --data "$hitter" \
            "$url" || { exit 1; }
        echo ""
    done < "$file"
}
url="$1"
wlfile="$2"
params=$(echo "$url" | cut -d"?" -f2)
new_url=$(echo "$url" | cut -d"?" -f1)
data=$params
brutus_one "$new_url" "$data" "$wlfile"
exit 0