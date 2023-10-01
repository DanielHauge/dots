#!/bin/bash

# Ask for input
choco install firefox -y
choco install neovim -y
git config --global core.editor nvim
choco install vlc -y
choco install wget -y
choco install ripgrep -y
choco install cargo -y
choco install winrar -y
choco install docker-desktop -y
choco install dotnet -y
choco install wsl2 -y
choco install 7zip -y
choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System' -y
choco install pwsh -y
choco install jq -y
choco install nerd-fonts-JetBrainsMono -y
choco install zig -y
choco install golang -y
choco install nodejs -y
choco install windirstat -y
choco install shellcheck -y
choco install glow -y
choco install javaruntime -y
choco install jdk8 -y
choco install pandoc -y
curl https://sh.rustup.rs -sSf | sh
choco install texlive -y --params="'/scheme:full'"
choco install InkScape -y
