#!/bin/bash
source "$DOTS_LOC"/bash/aliases.sh
source "$DOTS_LOC"/bash/easy-git.sh
source "$DOTS_LOC"/bash/environment.sh
source "$DOTS_LOC"/bash/easy-tex.sh
source "$DOTS_LOC"/bash/easy-rename.sh
source "$DOTS_LOC"/bash/easy-termlinq.sh
source "$DOTS_LOC"/bash/easy-pack.sh
source "$DOTS_LOC"/bash/easy-chatgpt.sh
source "$DOTS_LOC"/bash/easy-plot.sh
source "$DOTS_LOC"/bash/easy-jira.sh

set +o posix

if command -v z &>/dev/null; then
	eval "$(zoxide init bash)"
else
	echo "z not found, defaulting to cd"
fi
