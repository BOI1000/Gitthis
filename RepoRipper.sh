#!/bin/bash
# RepoRipper.sh going nuclear
# This script is designed to clone a git repository and extract all files from it.

# Initial checks and help message

help_message() {
    echo """
    Usage: $0 <.git url> <output directory>

    This script clones a .git directory from a remote repository and restores it locally.

    Arguments:
    <.git url>       The URL of the .git directory to clone.
    <output directory> The directory where the cloned repository will be saved.

    example:
    $0 http://example.com/repo.git /path/to/output"""
    exit 0
}

if [[ "$1" == "--help" || "$#" -ne 2 ]]; then
    help_message
elif ! command -v wget &>/dev/null || ! command -v git &>/dev/null; then
    echo "[ERROR] Required tools (wget, git) are not installed."
    echo "Please install wget and git to use this script:"
    echo -e "\tsudo apt install wget git -y"
    exit 1
fi

# Displaying the script header (most important part of the script)
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
echo -e "RepoRipper.sh v0.1 - Do you git it? - by @Deemon\n"
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
    echo -n "[$task]    "
    while kill -0 $pid 2>/dev/null; do
        temp=${spinstr#?}
        printf "\b\b\b[%c]" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\b\b\b[Done]\n" # the spinnies
}
# Checking function
checks() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        help_message
        exit 1
    elif ! [[ "$1" =~ ^https?://[a-zA-Z0-9./_-]+\.git$ ]]; then
        echo "[ERROR] Invalid .git URL: $1"
        exit 1
    elif [ ! -d "$2" ]; then
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
        if [ $? -ne 0 ]; then
            echo "[ERROR] Failed to move files to .git directory."
            exit 1
        fi
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
# Will add more features in the future (like colors and options). Will add versions so like... this is v0.1 yep yep
# Small changes will not be noted in the versioning system, only major changes will be recongized.
# lemme add like a banner down here or something
#  __________________________________________________
# |                                                  |
# |                                                  |
# |                this is a banner                  |
# |                                                  |
# |                                                  |
# |__________________________________________________|