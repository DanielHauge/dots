#!/bin/bash

if [ -z "$DOTS_LOC" ]; then
    export DOTS_LOC="$HOME/dots"
fi

if [ -z "$REPO_DIR" ]; then
    export REPO_DIR="$HOME/repo"
fi
source $DOTS_LOC/bash/shared_source.sh
if [ -f /opt/ros/jazzy/setup.bash ]; then
    source /opt/ros/jazzy/setup.bash
fi
