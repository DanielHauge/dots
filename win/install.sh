#!/bin/bash

packs=(
	"firefox"
	"GoogleChrome"
	"neovim"
	"tree-sitter"
	"make"
	"mingw"
	"dart-sdk"
	"flutter"
	"Temurin21jre"
	"vlc"
	"wget"
	"ripgrep"
	"cargo"
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
	"javaruntime"
	"jdk8"
	"Temurin21jre"
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
)

installed_packs=$(choco list --local-only)

for pack in "${packs[@]}"; do
	if ! echo "$installed_packs" | grep -q "$pack"; then
		echo "Installing $pack"
		choco install "$pack" -y
	fi
done

git config --global core.editor nvim

if ! command -v ckmake &>/dev/null; then
	echo "Installing ckmake"
	choco install ckmake --installargs 'ADD_CMAKE_TO_PATH=System' -y
fi

if ! command -v rustc &>/dev/null; then
	echo "Installing rust"
	curl https://sh.rustup.rs -sSf | sh
fi

if ! dotnet nuget list source | grep -q "https://api.nuget.org/v3/index.json"; then
	dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
fi

if ! command -v ascii-image-converter &>/dev/null; then
	echo "Installing ascii-image-converter"
	cargo install github.com/TheZoraiz/ascii-image-converter@latest
fi

# Install texlive can take time.
# choco install texlive -y --params="'/scheme:full'"

choco upgrade all
