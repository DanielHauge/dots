#!/bin/bash

# Exit if not admin
if ! net session &>/dev/null; then
	echo "Please run as admin"
	exit
fi

packs=(
	"Firefox"
	"GoogleChrome"
	"miktex"
	"neovim"
	"dbeaver"
	"tree-sitter"
	"make"
	"mingw"
	"dart-sdk"
	"balabolka"
	"flutter"
	"vlc"
	"Wget"
	"ripgrep"
	"winrar"
	"docker-desktop"
	"7zip"
	"pwsh"
	"jq"
	"nerd-fonts-JetBrainsMono"
	"zig"
	"golang"
	"nodejs"
	"python3"
	"ruff"
	"openjdk"
	"mvndaemon"
	"dotnet"
	"dotnet-sdk"
	"dotnet-6.0-sdk"
	"dotnet-5.0-sdk"
	"visualstudio2022-workload-universalbuildtools"
	"visualstudio2022-workload-universal"
	"windirstat"
	"shellcheck"
	"glow"
	"pandoc"
	"InkScape"
	"sumatrapdf"
)

installed_packs=$(choco list)

for pack in "${packs[@]}"; do

	if ! echo "$installed_packs" | grep -q -i "$pack"; then
		echo "Installing $pack"
		choco install "$pack" -y
	fi
done

# Update bash session with PATH etc.
source ~/.bashrc

# If java is not installed install it and set JAVA_HOME
if ! command -v java &>/dev/null; then
	echo "Installing java"
	choco install jdk8 -params 'installdir=c:\\java8' -y
	export JAVA_HOME="C:\java8"
	echo "export JAVA_HOME=\"$JAVA_HOME\"" >>~/.bashrc

fi

git config --global core.editor nvim

# if ! command -v ckmake &>/dev/null; then
# 	echo "Installing ckmake"
# 	choco install ckmake --installargs 'ADD_CMAKE_TO_PATH=System' -y
# fi

if ! command -v rustc &>/dev/null; then
	echo "Installing rust"
	# Install rustup with -y
	curl https://sh.rustup.rs -sSf | sh -s -- -y
fi

if ! dotnet nuget list source | grep -q "https://api.nuget.org/v3/index.json"; then
	dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
fi

#if ! command -v ascii-image-converter &>/dev/null; then
#	echo "Installing ascii-image-converter"
#	bash -c 'cargo install github.com/TheZoraiz/ascii-image-converter@latest'
#fi

# Install texlive can take time.
# choco install texlive -y --params="'/scheme:medium'"
# choco install texlive -y --params="'/scheme:full'" --force --execution-timeout 27000
