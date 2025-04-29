#!/bin/bash
function brutus_one() {
    local url="$1" # local variables here are cleaner than the original script + $1,$2,$3 were not quoted
    local data="$2"
    local file="$3"
    while read -r line; do # there used to be an unused variable here: "nothing"
        if echo "$data"|grep -q "HIT"; then
            hitter=$(echo "$data"|sed "s/HIT/$line/g" 2>/dev/null)
        fi
        echo "$hitter" # this was used to debug the script but might stay for the future script
        agents=$("Mozila/5.0" "Chrome/100.0" "Safari/537.36" "Opera/9.80" "Edge/18.18362")
        ua=${agents[$RANDOM % ${#agents[@]}]}
        curl -A "$ua" -v -L --data "$hitter" "$url" && echo ""
    done < "$file"
    wait # this was not in the original script
}
url="$1" # used to be a gap here + $1,$2 were not quoted
wlfile="$2"
params=$(echo "$url"|cut -d"?" -f2)
new_url=$(echo "$url"|cut -d"?" -f1)
if echo "$params"|grep -q "&"; then
    data=$(echo "$params") # this is a pointless variable, but keeping it for the sake of the original script
    brutus_one "$new_url" "$data" "$wlfile"
    exit 1 # this was not in the original script
fi