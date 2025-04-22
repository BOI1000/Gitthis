#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 [.git_url] [local_path]"
  exit
fi

url=$1
folder=$2

echo "[INFO] Dumping .git directory from $url"
wget -q -r -np -nH --cut-dirs=1 --reject "index.html*" -P "$folder" "$url"

echo "[INFO] Building repo..."
cd "$folder" || { echo "[ERROR!] Check your path!"; exit 1; }

if [ ! -d ".git" ]; then
  mkdir -p .git
  mv * .git/ 2>/dev/null
fi

echo "[INFO] Restoring repo from .git ..."
git checkout . 2>/dev/null

if [ $? -eq 0 ]; then
  echo "[INFO] Repo successfully rebuilt!"
  git log --oneline --graph --all
else
  echo "[ERROR] Failed to rebuild with 'git checkout .' - try doing this manually inside $folder"
fi
# the orginal script before RepoRipper.sh