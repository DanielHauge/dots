#!/bin/bash
# shellcheck disable=1090,1091

# if DOTS_LOC is not defined set ~/dots
if [ -z "$DOTS_LOC" ]; then
    export DOTS_LOC="$HOME/dots"
fi

if [ -z "$REPO_DIR" ]; then
    export REPO_DIR="$HOME/repo"
fi

if [ -f ~/.zshrc ]; then
    if [ -f "$DOTS_LOC"/zsh/.zshrc ]; then
        source "$DOTS_LOC"/zsh/.zshrc
    fi
    source ~/.zshrc
fi

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
source "$DOTS_LOC"/bash/easy-open.sh
source "$DOTS_LOC"/bash/easy-dotsauth.sh

if [ -n "$POSIX" ]; then
    source "$DOTS_LOC"/bash/easy-cal.sh
    # if command -v starship &>/dev/null; then
    #     export STARSHIP_CONFIG="$DOTS_LOC"/bash/starship.toml
    #     eval "$(starship init bash)"
    # else
    #     echo "starship not found"
    # fi
    set -o posix
fi
