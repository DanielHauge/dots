#!/bin/bash
# shellcheck disable=2142
x() {
	if [ "$#" -eq 0 ]; then
		while read -r line; do
			if [ -e "$line" ]; then
				unix_path=$(realpath "$line")
				windows_path=$(echo "$unix_path" | sed 's/^\///' | sed 's/\//\\/g' | sed 's/^./\0:/' | sed 's/::/:/')
				echo "Opening: $windows_path"
				explorer "$windows_path"
			else
				echo "Path does not exist: $line"
			fi
		done
	fi
	for i in "$@"; do
		if [ -e "$i" ]; then
			unix_path=$(realpath "$i")
			windows_path=$(echo "$unix_path" | sed 's/^\///' | sed 's/\//\\/g' | sed 's/^./\0:/')
			echo "Opening: $windows_path"
			explorer "$windows_path"
		else
			echo "Path does not exist: $i"
		fi
	done

}
alias repo='cd $REPO_DIR'
alias rpeo='cd $REPO_DIR' # typo
alias bconf='source ~/.bashrc'
alias vi='nvim'
alias vim='nvim'
alias nvi='nvim'
alias sl='ls'
alias ls='ls -F --color=auto'
alias ll='ls -l -h --time-style=long-iso --color=auto'
alias cya='shutdown -s -t 0'
alias bye='shutdown -s -t 0'
alias reboot='shutdown -r -t 0'
alias bc='python -c "from __future__ import division; from math import *; import sys; print(eval(sys.argv[1]))"'
alias restart='shutdown -r -t 0'
alias off='shutdown -s -t 0'
alias bios='shutdown -r -t 0 -fw'
alias bootusb='shutdown -r -t 0 -o'
alias rmd='cat *.md | glow '
alias todo='cat $REPO_DIR/*/TODO.md | glow'
export WINDOWS_TERMINAL_EXECUTE_COMMAND="'/c start wt.exe'"
alias wt='wt --startingDirectory "$(pwd -W)"'
alias wta='powershell "Start-Process -Verb RunAs cmd.exe $WINDOWS_TERMINAL_EXECUTE_COMMAND"'
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
