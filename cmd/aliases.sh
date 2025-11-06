if command -v zoxide &>/dev/null; then
    # if zsh then init zsh
    if [ -n "$ZSH_VERSION" ]; then
        eval "$(zoxide init zsh)"
        alias cd='z'
    else
        eval "$(zoxide init bash)"
        alias cd='z'
    fi
else
    echo "z not found, defaulting to cd"
fi

if ! command -v firefox &>/dev/null; then
    alias firefox='firefox.exe'
fi

if command -v bat &>/dev/null; then
    alias cat='bat'
    alias catw='watch -n 1 bat -f'
else
    alias catw='watch -n 1 cat'
fi

alias repo="cd $REPO_DIR"
alias rpeo="cd $REPO_DIR" # typo
alias suvi='sudo -E nvim'
alias vi='nvim'
alias cp='cpv --progress'
alias vim='nvim'
alias lg='lazygit'
# alias grep='rg -S'
alias nvi='nvim'
alias shadafix='rm -rf "$XDG_STATE_HOME"/nvim-data/shada'
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
alias ssh-keys='curl https://github.com/danielhauge.keys'
# alias fix-tsv=sed ':a;N;$!ba;s/"\([^"]*\)\n\([^"]*\)"/"\1;\2"/g'

if command -v eza &>/dev/null; then
    alias sl='eza -F --color=auto --icons'
    alias ls='eza -F --color=auto --icons'
    alias ll='eza -l -h --time-style=long-iso --color=auto --icons'
    alias lt='eza -l -h -T --icons --git-ignore'
    alias lta='eza -l -h -T --icons'
    alias watch-ls="watch -n 1 'eza -F --color=always --icons'"
    alias watch-lt="watch -n 1 'eza -l -h -T --icons --git-ignore --color=always'"
else
    alias ls='ls -F --color=auto'
    alias sl='ls'
    alias ll='ls -l -h --time-style=long-iso --color=auto'
    alias watch-ls="watch -n 1 'ls -F --color=always'"
    alias watch-lt="watch -n 1 'ls -l -h --time-style=long-iso --color=always'"
fi
alias dots-stow='stow -v --adopt -t ~/.config -d ~/dots .config; stow -v --adopt -t ~ -d ~/dots home'

alias plex='nohup setsid snap run plex-desktop >/dev/null 2>&1 < /dev/null &'
alias awk1='awk "{print \$1}"'
alias awk2='awk "{print \$2}"'
alias awk3='awk "{print \$3}"'
alias pacman='sudo pacman'
alias awk4='awk "{print \$4}"'
alias awk5='awk "{print \$5}"'
alias eject='sudo eject'
alias dots='cd $DOTS_LOC'

if command -v dysk &>/dev/null; then
    alias df='dysk'
else
    alias df='df -h'
fi

alias mp4tomp3='for i in *.mp4; do ffmpeg -i "$i" "${i%.*}.mp3"; done'
