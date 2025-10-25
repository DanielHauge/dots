export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="bira"
# zstyles gives error on startup, only run if running zsh
if [ -n "$ZSH_VERSION" ]; then
    zstyle ':omz:update' mode auto
fi

ENABLE_CORRECTION="true"


# if xdg_current_desktop isn't set, set it to Hyprland
if [ -z "$XDG_CURRENT_DESKTOP" ]; then
    export XDG_CURRENT_DESKTOP="Hyprland"
fi


ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline" 
plugins=(
	zsh-syntax-highlighting	 
	zsh-autosuggestions
    command-not-found
	web-search
    # dotnet
    docker
    zsh-interactive-cd
    sudo
)


if [ -z "$DOTS_LOC" ]; then
	export DOTS_LOC="$HOME/dots"
fi

if [ -z "$REPO_DIR" ]; then
	export REPO_DIR="$HOME/repo"
fi


export PATH="$HOME/snap/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/bin":$PATH


source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

export PATH="$PATH:$HOME/.dotnet/tools"

[[ -f /home/archie/.dart-cli-completion/zsh-config.zsh ]] && . /home/archie/.dart-cli-completion/zsh-config.zsh || true

if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

source $DOTS_LOC/cmd/setup.sh
