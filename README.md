# The dots

This is my collection of user settings / dot files and initialization for quick setup of new development environment.

## Install on Windows

```pwsh
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

```pwsh
choco install git.install --params "'/PseudoConsoleSupport /FSMonitor /Symlinks /WindowsTerminalProfile /NoGuiHereIntegration'" -y
```

In bash

```sh
git clone git@github.com:DanielHauge/dots.git
dots/setup.sh
$DOTS_LOC/win/install.sh
```
