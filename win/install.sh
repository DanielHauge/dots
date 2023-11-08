#!/bin/bash

# Ask for input
choco install firefox -y
choco install GoogleChrome -y
choco install neovim -y
choco install tree-sitter -y
git config --global core.editor nvim
choco install oh-my-posh -y
choco install make -y
choco install mingw -y
choco install dart-sdk -y
choco install flutter -y
choco install Temurin21jre -y
choco install vlc -y
choco install wget -y
choco install ripgrep -y
choco install cargo -y
choco install winrar -y
choco install docker-desktop -y
choco install dotnet -y
choco install dotnet-sdk -y
choco install dotnet-6.0-sdk -y
choco install dotnet-5.0-sdk -y
choco install visualstudio2022-workload-universalbuildtools -y
choco install visualstudio2022-workload-universal -y
dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
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
choco install python3 -y
choco install ruff -y # fast python linter
choco install javaruntime -y
choco install jdk8 -y
choco install pandoc -y
curl https://sh.rustup.rs -sSf | sh
choco install InkScape -y
go install github.com/TheZoraiz/ascii-image-converter@latest
# Install texlive can take time.
# choco install texlive -y --params="'/scheme:full'"
