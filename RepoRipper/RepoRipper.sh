#!/bin/bash
initColors() {
    if [ "$nocolor" != true ]; then
        red='\033[0;31m'
        grn='\033[0;32m'
        blu='\033[1;34m'
        rst='\033[0m'
    fi
}
log() {
    local level=$1
    local message=$2
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message"
}
gGrep() {
    initColors
    local grep="$1"
    IFS="," read -ra keywords <<< "$grep"
    for k in "${keywords[@]}"; do
        log "${grn}INFO${rst}" "Searching repo for $k"
        git grep -i "$k" || {
            log "${red}ERROR${rst}" "$k not found";
        }
    done
    exit 0
}
help_message() {
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "RepoRipper.sh - Clone and restore a remote .git directory."
    echo ""
    echo "Options:"
    echo "  -u, --url <.git url>         The URL of the remote .git directory to clone. (required)"
    echo "  -f, --folder <directory>     Output directory for the restored repository. (default: repo)"
    echo "  -lf, --log-file <file>       Log file to write output to. (default: repoRipper.log)"
    echo "  -nc, --no-color              Disable colored output."
    echo "  -h, --help                   Show this help message and exit."
    echo ""
    echo "  --gG, --grep <k1,k2>         Run a git grep for comma-separated keywords like emails, usernames, etc."
    echo "Example:"
    echo "  $0 -u http://example.com/.git -f myrepo -lf mylog.log"
    echo ""
    exit 0
}
Banner() {
    echo -e "${red}"
    cat << "EOF"
    __________                    __________.__
    \______   \ ____ ______   ____\______   \__|_____ ______   ___________
    |       _// __ \\____ \ /  _ \|       _/  \____ \\____ \_/ __ \_  __ \
    |    |   \  ___/|  |_> >  <_> )    |   \  |  |_> >  |_> >  ___/|  | \/
    |____|_  /\___  >   __/ \____/|____|_  /__|   __/|   __/ \___  >__|
            \/     \/|__|                 \/   |__|   |__|        \/

EOF
    echo -e "${rst}"
    echo -e "RepoRipper.sh v1.0 - OWASP - by @${red}theRealHacker${rst}\n"
}
spin() {
    local pid=$1
    local task=$2
    local delay=0.1
    local spinstr='|/-\'
    local temp
    echo -en "[$task]    " >&2
    while kill -0 $pid 2>/dev/null; do
        temp=${spinstr#?}
        printf "\b\b\b[%c]" "$spinstr" >&2
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\b\b\b[${grn}Done${rst}]\n" >&2
}
checks() {
    local url="$1"
    local folder="$2"
    if [ -z "$url" ]; then
        help_message
    elif [[ ! "$url" =~ ^https?://[a-zA-Z0-9./_-]+\.git$ ]]; then
        log "${red}ERROR${rst}" "Invalid .git URL: $url"
        exit 1
    elif [ -e "$folder" ] && [ ! -d "$folder" ]; then
        log "${red}ERROR${rst}" "Output path $folder exists and is not a directory."
        exit 1
    elif [ -d "$folder" ]; then
        log "${blu}INFO${rst}" "Directory $folder already exists. Proceeding with the script."
    elif [ ! -d "$folder" ]; then
        log "${blu}INFO${rst}" "Creating directory $folder"
        mkdir -p "$folder" 2>/dev/null && \
            log "${blu}INFO${rst}" "Directory $folder created successfully" || {
            log "${red}ERROR${rst}" "Failed to create directory $folder"
            exit 1
        }
    fi
    if ! command -v wget &>/dev/null || ! command -v git &>/dev/null; then
        log "${red}ERROR${rst}" "Required tools (wget, git) are not installed."
        echo "Please install wget and git to use this script:"
        echo -e "\tsudo apt install wget git -y"
        exit 1
    fi
}
Main() {
    local url=$1
    local folder=$2

    log "${blu}INFO${rst}" "Dumping .git directory from $url"
    wget -q -r -np -nH --cut-dirs=1 --reject "index.html*" -P "$folder" "$url" &
    wget_pid=$!
    spin $wget_pid "${blu}Downloading .git directory${rst}"
    wait $wget_pid
    if [ $? -ne 0 ]; then
        log "${red}ERROR${rst}" "An error occurred while downloading the .git directory."
        exit 1
    fi

    log "${blu}INFO${rst}" "Building git repository from $url"
    cd "$folder" || exit 1
    if [ ! -d ".git" ]; then # will update this next time
        rm -rf .git && mkdir -p ".git" && mv * .git/ 2>/dev/null || \
            { log "${red}ERROR${rst}" "Failed to move files to .git directory"; exit 1; }
    fi

    log "${blu}INFO${rst}" "Restoring git repository from $url"
    git checkout . &>/dev/null && log "${grn}INFO${rst}" "Repository restored successfully" || \
        { log "${red}INFO${rst}" "Failed to restore repository."; exit 1; }
    log "${blu}INFO${rst}" "Repository log:"
    git log --oneline --graph --decorate --all
    log "${blu}INFO${rst}" "Repository status:"
    git status
}
url=""
folder="repo"
log_file="repoRipper.log"
nocolor=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--url)
            if [[ -z "$2" || "$2" == -* ]]; then
                log "${red}ERROR${rst}" "$1 requires an argument."
                help_message
            fi
            url="$2"; shift 2;;
        -f|--folder)
            if [[ -z "$2" || "$2" == -* ]]; then
                log "${red}ERROR${rst}" "$1 requires an argument."
                help_message
            fi
            folder="$2"; shift 2;;
        -lf|--log-file)
            if [[ -z "$2" || "$2" == -* ]]; then
                log "${red}ERROR${rst}" "$1 requires an argument."
                help_message
            fi
            log_file="$2"; shift 2;;
        -gG|--grep)
            if [[ -z "$2" || "$2" == -* ]]; then
                log "${red}ERROR${rst}" "$1 requires an argument."
                help_message
            fi
            gGrep "$2"; shift 2;;
        -nc|--no-color)
            nocolor=true; shift;;
        -h|--help)
            help_message;;
        *)
            shift;;
    esac
done
initColors
Banner
checks "$url" "$folder"
exec > >(tee -a "$log_file") 2>&1
log "${blu}INFO${rst}" "Logging to $log_file"
Main "$url" "$folder"
log "${grn}FIN${rst}" "Script execution completed."
exit 0
#  __________________________________________________
# |                                                  |
# |                                                  |
# |            RepoRipper going nuclear              |
# |                                                  |
# |                                                  |
# |__________________________________________________|