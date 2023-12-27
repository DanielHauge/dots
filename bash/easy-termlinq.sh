#!/bin/bash

# From standard input, take the first n inputs
take() {
	local n=$1
	local i=0
	while read line; do
		if [ $i -lt $n ]; then
			echo $line
			i=$((i + 1))
		else
			break
		fi
	done
}

# From standard input, skip the first n inputs, then return the rest
skip() {
	local n=$1
	local i=0
	while read line; do
		if [ $i -lt $n ]; then
			i=$((i + 1))
		else
			echo $line
		fi
	done
}

# Pick the nth element from standard input
pick() {
	local n=$1
	local i=0
	while read line; do
		if [ $i -eq $n ]; then
			echo $line
			break
		else
			i=$((i + 1))
		fi
	done
}
