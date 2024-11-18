#!/bin/bash
# shellcheck disable=2142

alias cal='calendar'

if command -v zoxide &>/dev/null; then
	# if zsh then init zsh
	if [ -n "$ZSH_VERSION" ]; then
		eval "$(zoxide init zsh)"
		alias cd='z'
	else
		eval "$(zoxide init bash)"
		alias cd='z'
	fi
else
	echo "z not found, defaulting to cd"
fi

function am() {
	"$@"
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
	alias catw='watch -n 1 bat -f'
else
	alias catw='watch -n 1 cat'
fi

alias repo="cd $REPO_DIR"
alias rpeo="cd $REPO_DIR" # typo
alias vi='nvim'
alias vim='nvim'
alias lg='lazygit'
alias grep='rg -S'
alias nvi='nvim'
alias shadafix='rm -rf "$XDG_STATE_HOME"/nvim-data/shada'
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
alias ssh-keys='curl https://github.com/danielhauge.keys'
# alias fix-tsv=sed ':a;N;$!ba;s/"\([^"]*\)\n\([^"]*\)"/"\1;\2"/g'

if command -v clip &>/dev/null; then
	function cfp() {
		if [ -f "$1" ]; then
			echo "$(pwd -W)/$1" | clip
			return
		fi
		echo "File $1 not found"
	}
fi

if command -v xclip &>/dev/null; then
	alias clip='xclip -selection clipboard'
fi

if command -v eza &>/dev/null; then
	alias sl='eza -F --color=auto --icons'
	alias ls='eza -F --color=auto --icons'
	alias ll='eza -l -h --time-style=long-iso --color=auto --icons'
	alias lt='eza -l -h -T --icons --git-ignore'
	alias lta='eza -l -h -T --icons'
	alias watch-ls="watch -n 1 'eza -F --color=always --icons'"
	alias watch-lt="watch -n 1 'eza -l -h -T --icons --git-ignore --color=always'"
else
	alias ls='ls -F --color=auto'
	alias sl='ls'
	alias ll='ls -l -h --time-style=long-iso --color=auto'
	alias watch-ls="watch -n 1 'ls -F --color=always'"
	alias watch-lt="watch -n 1 'ls -l -h --time-style=long-iso --color=always'"
fi
alias dots-src='source $DOTS_LOC/bash/shared_source.sh'

# if windows
if [ -n "$WINDIR" ]; then
	alias cya='shutdown.exe -s -t 0'
	alias bye='shutdown.exe -s -t 0'
	alias reboot='shutdown.exe -r -t 0'
	alias bc='python -c "from __future__ import division; from math import *; import sys; print(eval(sys.argv[1]))"'
	alias restart='shutdown.exe -r -t 0'
	alias off='shutdown.exe -s -t 0'
	alias bios='shutdown.exe -r -t 0 -fw'
	alias bootusb='shutdown.exe -r -t 0 -o'
	alias nas="wt.exe -p 'Git Bash' -d //nas/vault"
	alias gwt="wt.exe -p 'Git Bash'"
	export WINDOWS_TERMINAL_EXECUTE_COMMAND="'/c start wt.exe'"
	alias wt='wt.exe --startingDirectory "$(pwd -W)"'
	alias wta='powershell.exe "Start-Process -Verb RunAs cmd.exe $WINDOWS_TERMINAL_EXECUTE_COMMAND"'
	# TODO: release this small tool
	alias winstall="$DOTS_LOC/win/install.sh"
else
	alias off='shutdown -h now'
fi

alias letitsnow="$DOTS_LOC/bash/snowjob.sh"
alias rmd='cat *.md | glow '
alias todo='cat $REPO_DIR/*/TODO.md | glow'
alias mmdcd='sudo docker run --rm -u `id -u`:`id -g` -v .:/data minlag/mermaid-cli -i'
# Start wt with profile git bash, and use //nas/vault as directory
alias awk1='awk "{print \$1}"'
alias awk2='awk "{print \$2}"'
alias awk3='awk "{print \$3}"'
alias awk4='awk "{print \$4}"'
alias awk5='awk "{print \$5}"'
alias dotnetprojs='dotnet sln list | skip 2 | awk "{print \$1}" | sed "s/\.csproj//g" | xargs -I {} find . -name "{}.dll" | grep bin/Debug'
alias dots='cd $DOTS_LOC'
# Run nvim in the dots directory
alias dots-vi='(cd $DOTS_LOC && nvim)'
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
