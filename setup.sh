#!/bin/bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "export DOTS_LOC=$SCRIPT_DIR" >>~/.bashrc
echo "source $DOTS_LOC/bash/.bashrc" >>~/.bashrc
source ~/.bashrc
