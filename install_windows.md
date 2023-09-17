# Setup

In powershell, download chocolatey

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

## Install stuff

```sh
choco install steam -y
choco install geforce-experience -y
choco install discord -y

```

```sh
choco install git.install --params "'/PseudoConsoleSupport /FSMonitor /Symlinks /WindowsTerminalProfile /NoGuiHereIntegration'" -y
choco install firefox -y
choco install vlc -y
choco install wget -y
choco install cargo -y
choco install winrar -y
choco install docker-desktop -y
choco install dotnet -y
choco install wsl2 -y
choco install 7zip -y
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
```

## Windows Terminal

```json
{
    "font": 
    {
        "face": "JetBrainsMono Nerd Font"
    },
    "opacity": 65,
    "useAcrylic": false
}
```

## nvim
In powershell

```shell
choco install neovim -y
```
Run ```:Copilot setup``` for  copilot authentication

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
