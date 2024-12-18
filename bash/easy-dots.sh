function dots-auth() {
	# if .ssh/*pub doesn't exist. create it.
	if [ ! -f ~/.ssh/id_rsa.pub ]; then
		echo "Missing ssh-key -> Generating a new one"
		ssh-keygen -t rsa -b 4096 -C "$(whoami)@$(hostname)-$(date +'%Y-%m-%d %H:%M:%S')"
	fi

	if command -v clip.exe &>/dev/null; then
		cat ~/.ssh/id_rsa.pub | clip.exe
		echo "Public key copied to clipboard"
	elif command -v xclip &>/dev/null; then
		cat ~/.ssh/id_rsa.pub | xclip -selection clipboard
		echo "Public key copied to clipboard"
	elif command -v pbcopy &>/dev/null; then
		cat ~/.ssh/id_rsa.pub | pbcopy
		echo "Public key copied to clipboard"
	fi

	echo "Public key:"
	cat ~/.ssh/id_rsa.pub

	echo "Register at: https://github.com/settings/ssh/new"
	echo "[Enter] when ssh-key is added to github"
	read -r
	cd ~/dots || exit
	git remote set-url origin $(git remote get-url origin | sed -e 's/^https:\/\/github.com\//git@github.com:/')
}

function dots-install() {
	# if windows run install in windows
	if [ -n "$WINDIR" ]; then
		echo "Windows detected"
		$DOTS_LOC/win/install.sh
		return
	fi
	# if ubuntu
	if command -v apt-get &>/dev/null; then
		echo "Ubuntu detected"
		$DOTS_LOC/ubuntu/install.sh
		return
	fi

	echo "Unsupported OS detected"

}
