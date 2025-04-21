#!/bin/bash
# RepoRipper.sh going nuclear
# This script is designed to clone a git repository and extract all files from it.

if [[ "$1" == "--help" || "$#" -eq 0 ]]; then
    echo "Usage: $0 <.git url> <output directory>"
    exit 0
fi
if ! command -v wget &>/dev/null || ! command -v git &>/dev/null; then
    echo "[ERROR] Required tools (wget, git) are not installed."
    exit 1
fi

echo -e "\e[1;31m"
cat << "EOF"

__________                    __________.__                            
\______   \ ____ ______   ____\______   \__|_____ ______   ___________ 
 |       _// __ \\____ \ /  _ \|       _/  \____ \\____ \_/ __ \_  __ \
 |    |   \  ___/|  |_> >  <_> )    |   \  |  |_> >  |_> >  ___/|  | \/
 |____|_  /\___  >   __/ \____/|____|_  /__|   __/|   __/ \___  >__|   
        \/     \/|__|                 \/   |__|   |__|        \/       
EOF
echo -e "\e[0m"
echo -e "[MSG] RepoRipper.sh - Do you git it? - by @Deemon\n"
# Enable logging
LOG_FILE="RepoRipper.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "[INFO] Logging started at $(date)"

# Spinner function for visual feedback
spin() {
    local pid=$1
    local task=$2
    local delay=0.1
    local spinstr='|/-\'
    local temp
    echo -n "[$task] "
    while kill -0 $pid 2>/dev/null; do
        temp=${spinstr#?}
        printf "\b%c" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\b"  # Clear the spinner character
    echo "[done]"
}
# Checking function
checks() {
    if [ -z "$1" ]; then
        echo "[ERROR] No .git URL provided."
        echo "[INFO] Usage: $0 <.git url> <output directory>"
        exit 1
    fi
    if [ "$#" -ne 2 ]; then
        echo "[ERROR] Usage: $0 <.git url> <output directory>"
        exit 1
    fi
    if ! [[ "$1" =~ ^https?://.*\.git$ ]]; then
        echo "[ERROR] Invalid .git URL: $1"
        exit 1
    fi
    if [ ! -d "$2" ]; then
        echo "[INFO] Creating directory $2"
        mkdir -p "$2" 2>/dev/null || {
            echo "[ERROR] Failed to create directory $2"
            exit 1
        }
    fi
}
# Main function
main() {
    local url=$1
    local folder=$2
    
    echo "[INFO] Dumping .git directory from $url"
    wget -q -r -np -nH --cut-dirs=1 --reject "index.html*" -P "$folder" "$url" &
    wget_pid=$!
    spin $wget_pid "Downloading .git directory"
    wait $wget_pid
    if [ $? -ne 0 ]; then
        echo "[ERROR] An error occurred while downloading the .git directory."
        exit 1
    fi
    
    echo "[INFO] Building git repository from $url"
    cd "$folder" || exit
    if [ ! -d ".git" ]; then
        rm -rf .git
        mkdir -p ".git"
        mv * .git/ 2>/dev/null
    elif [ -f ".git" ]; then
        echo "[INFO] changing .git to a directory."
        mv .git .git.old
        rm -rf .git
        mkdir -p ".git"
        mv * .git/ 2>/dev/null
    fi
    
    echo "[INFO] Restoring git repository from $url"
    git checkout . &>/dev/null
    git_pid=$!
    spin $git_pid "Restoring repository"
    wait $git_pid
    if [ $? -eq 0 ]; then
        echo "[INFO] Repository restored successfully."
        echo "[INFO] Repository log:"
        git log --oneline --graph --decorate --all
        echo "[INFO] Repository status:"
        git status
    else
        echo "[ERROR] Failed to restore repository."
        exit 1
    fi
}
# Main script execution
url=$1
folder=$2
checks "$url" "$folder"
main "$url" "$folder"
echo "[FIN] Script execution completed at $(date)"
# End of script
# This script is designed to clone a git repository and extract all files from it.
# It uses wget to download the .git directory and then restores the repository using git.
# Get ready for post upload testing :/
