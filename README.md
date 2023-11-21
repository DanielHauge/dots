# The dots

This is my collection of user settings / dot files and initialization for quick setup of new development environment.

## Install on Windows

```pwsh
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
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
```
