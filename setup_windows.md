# Setup

In powershell, download chocolatey

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

## Install stuff

```sh
choco install firefox -y
choco install vlc -y
choco install winrar -y
choco install steam -y
choco install geforce-experience -y
choco install docker-desktop -y
choco install discord -y
choco install jq -y
choco install windirstat -y
choco install shellcheck -y
choco install git.install --params "'/PseudoConsoleSupport /FSMonitor /Symlinks /WindowsTerminalProfile /NoGuiHereIntegration'" -y
```

## nvim
In powershell

```shell
choco install neovim -y
git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
```

## vs code

```sh
choco install vscode -y
echo '{"window.zoomLevel":2,"editor.cursorSurroundingLines":7}' > $APPDATA/code/User/settings.json
code --install-extension VisualStudioExptTeam.vscodeintellicode
code --install-extension eamodio.gitlens
code --install-extension GitHub.copilot
code --install-extension yzhang.markdown-all-in-one
code --install-extension timonwong.shellcheck
```