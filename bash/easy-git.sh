#!/bin/bash

alias gs='git status -s -b --show-stash --ahead-behind'
# Set gitconfig file location
git config --global include.path $DOTS_LOC/bash/.gitconfig

function gcm() {
	if command -v commitlint &>/dev/null; then
		if echo "$1" | commitlint lint; then
			git commit -m "$1"
		fi
	else
		echo "❌Commiting without linting!❌"
		git commit -m "$1"
	fi
}

function gp() {
	# Use tee to print the output of the command to the terminal and to a file
	# Get last part of uri
	uri=$(git remote get-url origin | sed 's/.*\///' | sed 's/.git//')
	branch=$(git branch --show-current)
	mkdir -p ~/.gitpush.logs/"$uri"
	# if branch starts with feat, fix, hotfix, release, refactor, style, test, chore, ci, build then mkdir -p that folder
	mkdir -p ~/.gitpush.logs/"$uri"/$(echo "$branch" | cut -d'/' -f1)

	gitpush_out=$(git push 2>&1 | tee ~/.gitpush.logs/"$uri"/"$branch".gitpush)
	echo "$gitpush_out"
	# Check if any lines contain a line starting with "remote: " and something with merge_request
	merge_request=$(echo "$gitpush_out" | grep "remote: " | grep "http" | sed -e 's/remote: //g' | tail -n 1 | tee ~/.gitpush.logs/"$uri"/"$branch".merge_request)
	echo "$merge_request"

}

function gpr() {
	uri=$(git remote get-url origin | sed 's/.*\///' | sed 's/.git//')
	branch=$(git branch --show-current)
	if [ -f ~/.gitpush.logs/"$uri"/"$branch".merge_request ]; then
		merge_request=$(cat ~/.gitpush.logs/"$uri"/"$branch".merge_request)
		if [ -n "$merge_request" ]; then
			echo "Opening merge request: $merge_request"
			x "$merge_request"
		else
			echo "No merge request found"
		fi
	else
		echo "No merge request found"
	fi
}

function gb() {

	localBranches=$(git branch -a | sed 's/*//g' | sed 's|remotes/origin/||g' | awk1 | sed 's/ //g' | sort -u | awk '$1 != "HEAD"{print}')
	chossenBranch=$(echo "$localBranches" | fzf --preview-window=right:80% --preview="git gbprev {}")
	if [[ -z $chossenBranch ]]; then
		echo "no branch"
		return
	fi

	localChanges=$(git status -s)
	if [[ -z $localChanges ]]; then
		echo "no local changes"
	else
		echo "Local changes detected:"
		git status -s
		echo -e "\nForce clean? (y/n)"
		read -r cleanChoice
		if [[ "$cleanChoice" = "y" ]]; then
			git clean -df
			git checkout .
		else
			echo "Canceling branching"
			return
		fi

	fi

	git checkout "$chossenBranch"

}

function gd() {
	# if first argument is a number
	if [[ $1 =~ ^[0-9]+$ ]]; then
		index=$1
	else
		index=1
	fi

	local file="$(git ls-files -d | head -$index)"
	if [ -n "$file" ]; then
		echo -e "Deleted file \033[41m $file\033[0m"
		echo -e "\033[91m$(git show HEAD:$file | sed -e 's/^/-/')\033[0m "
		return
	fi

	local file="$(git ls-files -m | head -$index)"
	if [ -n "$file" ]; then
		git diff $file
		return
	fi

	local file="$(git ls-files -o | head -$index)"
	if [ -n "$file" ]; then
		echo -e "Added new file \033[44m\033[92m $file \033[0m "
		while read p; do
			echo -e "\033[92m+$p\033[0m"
		done <$file
		return
	fi

	echo "No file to diff"

	git status
}

function ga() {
	index=1

	if [[ $1 =~ ^[0-9]+$ ]]; then
		index=$1
	fi
	local file="$(git ls-files -d | head -$index)"
	if [ -n "$file" ]; then
		git add $file
		git status
		return
	fi

	local file="$(git ls-files -m | head -$index)"
	if [ -n "$file" ]; then
		git add $file
		git status
		return
	fi

	local file="$(git ls-files -o | head -$index)"
	if [ -n "$file" ]; then
		git add $file
		git status
		return
	fi

	echo "No file to add"

	git status
}

function gc() {

	index=1

	if [[ $1 =~ ^[0-9]+$ ]]; then
		index=$1
	fi
	local file="$(git ls-files -d | head -$index)"
	if [ -n "$file" ]; then
		git restore $file
		echo "Restored $file from head"
		git status
		return
	fi

	local file="$(git ls-files -m | head -$index)"
	if [ -n "$file" ]; then
		git restore $file
		echo "Restored $file from head"
		git status
		return
	fi

	local file="$(git ls-files -o | head -$index)"
	if [ -n "$file" ]; then
		rm $file
		echo "Removed $file"
		git status
		return
	fi

	echo "No file to restore"

	git status
}

function grm() {

	index=1

	if [[ $1 =~ ^[0-9]+$ ]]; then
		index=$1
	fi
	local file="$(git ls-files --format='%(path)' | head -$index)"
	if [ -n "$file" ]; then
		git rm --cached $file
		echo "Removed $file from staging"
		git status
		return
	fi

	echo "No file to remove from staging"
}
