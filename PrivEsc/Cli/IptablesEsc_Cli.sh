#!/bin/bash
Help() 
{
    echo "Work in progress" # TODO
}
initColors()
{
    if [ ! "$nocolor" = true ]; then
        red=$(printf '\033[1;31m')
        green=$(printf '\033[1;32m')
        yellow=$(printf '\033[1;33m')
        blue=$(printf '\033[1;34m')
        bl=$(printf '\033[0;34m')
        orange=$(printf '\033[1;38;2;255;165;0m')
        reset=$(printf '\033[0m')
    fi
}
Banner()
{
    echo "╔══════════════════════════════╗"
    echo "║     IPTABLES ESCer Cli       ║"
    echo "╚══════════════════════════════╝"
    echo -e "\t\tby @theRealHacker"; echo ""
}
lline()
{
    echo "========================================================================================================="
}
initCheck()
{
    initSudo=$(sudo -l)
    if echo "$initSudo" | grep -Eq '(NOPASSWD: /usr/sbin/iptables|NOPASSWD: /usr/sbin/iptables-save)'; then
        echo "$yellow[*]$reset Target might be vulnerable"
        lline
        echo "$initSudo"
        lline
    elif echo "$initSudo" | grep -q "NOPASSWD: ALL"; then
        echo "$green[+]$reset $USER has NOPASSWD: ALL privilege"
        lline
        echo "$initSude"
        lline
    fi
    if [[ ! -z "$pubkey" && -f "$pubkey" ]] && [[ "$pubkey" =~ \.pub$ ]]; then
        echo "$blue[*]$reset Public key: $pubkey"
    elif [[ ! -z "$pubkey" && ! -f "$pubkey" ]]; then
        echo "$orange[!]$reset Public key: None ($pubkey does not exist)"
    elif [[ -z "$pubkey" ]]; then
        echo "$yellow[*]$reset Public key: None"
    else
        echo "$orange[!]$reset Public key: None (Public key must end with .pub)"
    fi
}
MakeKey()
{
    if [ "$isfn" = true ]; then
        ssh-keygen -t ed25519 -b 4096 -f "$fn"
    else
        ssh-keygen -t ed25519 -b 4096 -f privesc_key
    fi
}
Flush()
{
    sudo iptables -F
}
while [[ $# -gt 0 ]]; do
    case "$1" in
        -k|--key)
            pubkey="$2"
            shift 2
            ;;
        -t|--target-file)
            target="$2"
            shift 2
            ;;
        -tu|--target-user)
            targetuser="$2"
            shift 2
            ;;
        -mk|--make-key)
            makekey=true
            shift
            ;;
        --mkfn|--mk-file-name)
            if [ "$makekey" = true ]; then
                isfn=true
                fn="$2"
            fi
            shift 2
            ;;
        --flush)
            flush=true
            shift
            ;;
        --no-color)
            flush=true
            shift
            ;;
        --check)
            check=true
            shift
            ;;
        *)
            echo "[!] Unknown option: $1"
            exit 1
            ;;
    esac
done
Banner
initColors
if [ "$check" = true ]; then
    initCheck
fi
# Work in progress