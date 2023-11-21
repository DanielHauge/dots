#!/bin/bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "# Daniels Bash" > ~/.bashrc
export DOTS_LOC=$SCRIPT_DIR
echo "export DOTS_LOC=$SCRIPT_DIR" >>~/.bashrc
echo "export REPO_LOC=~/repo" >>~/.bashrc
echo "source $DOTS_LOC/bash/.bashrc" >>~/.bashrc
source ~/.bashrc
