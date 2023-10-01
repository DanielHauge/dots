#!/bin/bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cp "$SCRIPT_DIR"/bash/.bashrc ~/.bashrc
sed -i "s|DOTS_LOC=HOME|DOTS_LOC=$SCRIPT_DIR|g" ~/.bashrc
source ~/.bashrc
