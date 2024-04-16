#!/bin/bash

x() {
	if [ "$#" -eq 0 ]; then
		# Try read from standard in, but if there is no standard in, do something else
		if [ -t 0 ]; then
			p=$(fd | fzf)
			if [ -z "$p" ]; then
				return 1
			fi
			unix_path=$(realpath "$p")
			windows_path=$(echo "$unix_path" | sed 's/^\///' | sed 's/\//\\/g' | sed 's/^./\0:/')
			echo "Opening: $windows_path"
			explorer "$windows_path"

			return 0
		fi
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
