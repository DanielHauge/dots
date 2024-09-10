#!/bin/bash
export GITHUB="https://github.com/DanielHauge"
# if windows:
if [[ "$OSTYPE" == "msys" ]]; then
	export XDG_CONFIG_HOME=$DOTS_LOC
	export XDG_DATA_HOME=$DOTS_LOC
	export XDG_STATE_HOME=$HOME
fi
