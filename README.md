# The dots

This is my collection of user settings / dot files and initialization for quick setup of new development environment.

## Install on Windows

```pwsh
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

```pwsh
choco install git.install --params "'/PseudoConsoleSupport /FSMonitor /Symlinks /WindowsTerminalProfile /NoGuiHereIntegration'" -y
```

In bash

```sh
git clone git@github.com:DanielHauge/dots.git
git config --global user.email "Animcuil@gmail.com"
git config --global user.name "Daniel Hauge"
dots/setup.sh
$DOTS_LOC/win/install.sh
git config --global core.excludeFile "$DOTS_LOC"/bash/.gitignore
git config --global push.autoSetupRemote true
```
