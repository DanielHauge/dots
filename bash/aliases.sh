#!/bin/bash
# shellcheck disable=2142

alias cal='calendar'

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
    alias cd='z'
else
    echo "z not found, defaulting to cd"
fi

function am() {
    while true; do
        await-modify "."
        clear
        "$@"
    done

}

if ! command -v firefox &>/dev/null; then
    alias firefox='firefox.exe'
fi

if command -v bat &>/dev/null; then
    alias cat='bat'
fi

alias repo="cd $REPO_DIR"
alias rpeo="cd $REPO_DIR" # typo
alias bconf='source ~/.bashrc'
alias vi='nvim'
alias vim='nvim'
alias grep='rg -S'
alias nvi='nvim'
alias sl='ls'
if command -v eza &>/dev/null; then
    alias ls='eza -F --color --icons'
    alias ll="ls -l -h --time-style=long-iso "
    alias lt="ls -T"
else
    alias ls='eza -F --color=auto'
    alias ll='ls -l -h --time-style=long-iso --color=auto'
fi
alias cya='shutdown.exe -s -t 0'
alias bye='shutdown.exe -s -t 0'
alias reboot='shutdown.exe -r -t 0'
alias bc='python -c "from __future__ import division; from math import *; import sys; print(eval(sys.argv[1]))"'
alias restart='shutdown.exe -r -t 0'
alias off='shutdown.exe -s -t 0'
alias bios='shutdown.exe -r -t 0 -fw'
alias bootusb='shutdown.exe -r -t 0 -o'
alias rmd='cat *.md | glow '
alias todo='cat $REPO_DIR/*/TODO.md | glow'
# Start wt with profile git bash, and use //nas/vault as directory
alias nas="wt.exe -p 'Git Bash' -d //nas/vault"
alias gwt="wt.exe -p 'Git Bash'"
export WINDOWS_TERMINAL_EXECUTE_COMMAND="'/c start wt.exe'"
alias wt='wt.exe --startingDirectory "$(pwd -W)"'
alias wta='powershell.exe "Start-Process -Verb RunAs cmd.exe $WINDOWS_TERMINAL_EXECUTE_COMMAND"'
# TODO: release this small tool
alias winstall="$DOTS_LOC/win/install.sh"
alias letitsnow="$DOTS_LOC/bash/snowjob.sh"
alias awk1='awk "{print \$1}"'
alias awk2='awk "{print \$2}"'
alias awk3='awk "{print \$3}"'
alias awk4='awk "{print \$4}"'
alias awk5='awk "{print \$5}"'
alias dotnetprojs='dotnet sln list | skip 2 | awk "{print \$1}" | sed "s/\.csproj//g" | xargs -I {} find . -name "{}.dll" | grep bin/Debug'
alias dots='cd $DOTS_LOC'
alias mp4tomp3='for i in *.mp4; do ffmpeg -i "$i" "${i%.*}.mp3"; done'
alias xa='xargs -I ½'
alias xcat='xa cat ½'
function cpc() {
    # First argument is the history number
    # If no argument is provided, echo bad
    if [ -z "$1" ]; then
        history
        echo "Usage: cpc <history_number>"
        return 1
    fi
    local history_number=$1
    local command=$(history | grep "^ *$history_number" | sed "s/^ *$history_number *//")
    echo "$command" | clip
}
