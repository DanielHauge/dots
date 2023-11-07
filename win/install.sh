#!/bin/bash

# Ask for input
choco install firefox -y
choco install GoogleChrome -y
choco install neovim -y
choco install tree-sitter -y
git config --global core.editor nvim
choco install make -y
choco install mingw -y
choco install dart-sdk -y
cohoc install flutter -y
choco install dotnet-sdk -y
choco install dotnet-runtime -y
choco install vlc -y
choco install wget -y
choco install ripgrep -y
choco install cargo -y
choco install winrar -y
choco install docker-desktop -y
choco install dotnet -y
choco install 7zip -y
choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System' -y
choco install pwsh -y
choco install jq -y
choco install nerd-fonts-JetBrainsMono -y
choco install zig -y
choco install golang -y
choco install nodejs -y
curl https://sh.rustup.rs -sSf | sh
choco install python3 -y
choco install ruff -y # fast python linter
choco install javaruntime -y
choco install jdk8 -y
choco install Temurin21jre -y
choco install windirstat -y
choco install shellcheck -y
choco install glow -y
choco install pandoc -y
choco install InkScape -y
go install github.com/TheZoraiz/ascii-image-converter@latest
# Install texlive can take time.
# choco install texlive -y --params="'/scheme:full'"
