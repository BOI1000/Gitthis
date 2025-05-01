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
    $0 http://example.com/.git /path/to/output
    """
    exit 1
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
echo -e "RepoRipper.sh v0.2 - Do you git it? - by @Deemon\n"
# Enable logging
LOG_FILE="repoRipper.log"
# TODO: Clean this part up v
exec > >(tee -a "$LOG_FILE") 2>&1
log() {
    local level=$1
    local message=$2
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message"
}
log "INFO" "Logging to $LOG_FILE"
# TODO: Clean this part up ^

# Spinner function for visual feedback
spin() {
    local pid=$1
    local task=$2
    local delay=0.1
    local spinstr='|/-\'
    local temp
    echo -n "[$task]    " >&2
    while kill -0 $pid 2>/dev/null; do
        temp=${spinstr#?}
        printf "\b\b\b[%c]" "$spinstr" >&2
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\b\b\b[Done]\n" >&2 # the spinnies
}
# Checking function
checks() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        help_message
    elif ! [[ "$1" =~ ^https?://[a-zA-Z0-9./_-]+\.git$ ]]; then
        log "ERROR" "Invalid .git URL: $1"
        exit 1
    elif [ -e "$2" ] && [ ! -d "$2" ]; then
        log "ERROR" "Output path $2 exists and is not a directory."
        exit 1
    elif [ -e "$2" ] && [ -d "$2" ]; then
        log "INFO" "Directory $2 already exists. Proceeding with the script."
    elif [ ! -d "$2" ]; then
        log "INFO" "Creating directory $2"
        mkdir -p "$2" 2>/dev/null || {
            log "ERROR" "Failed to create directory $2"
            exit 1
        }
    fi
}
# Main function
main() {
    local url=$1
    local folder=$2
    
    log "INFO" "Dumping .git directory from $url"
    wget -q -r -np -nH --cut-dirs=1 --reject "index.html*" -P "$folder" "$url" &
    wget_pid=$!
    spin $wget_pid "Downloading .git directory"
    wait $wget_pid
    if [ $? -ne 0 ]; then
        echo "[ERROR] An error occurred while downloading the .git directory."
        rm -rf "$folder"
        exit 1
    fi
    
    log "INFO" "Building git repository from $url"
    cd "$folder" || exit
    if [ ! -d ".git" ]; then
        rm -rf .git
        mkdir -p ".git"
        mv * .git/ 2>/dev/null
        if [ $? -ne 0 ]; then
            log "ERROR" "Failed to move files to .git directory."
            exit 1
        fi
    fi
    
    log "INFO" "Restoring git repository from $url"
    git checkout . &>/dev/null
    git_pid=$!
    spin $git_pid "Restoring repository"
    wait $git_pid
    if [ $? -eq 0 ]; then
        log "INFO" "Repository restored successfully."
        echo "[INFO] Repository log:"
        git log --oneline --graph --decorate --all
        echo "[INFO] Repository status:"
        git status
    else
        log "ERROR" "Failed to restore repository."
        exit 1
    fi
}
url=$1
folder=$2
checks "$url" "$folder"
main "$url" "$folder"
log "FIN" "Script execution completed."
# v0.2 is untested. Should be working.
#  __________________________________________________
# |                                                  |
# |                                                  |
# |                this is a banner                  |
# |                                                  |
# |                                                  |
# |__________________________________________________|