export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="bira"
# zstyles gives error on startup, only run if running zsh
if [ -n "$ZSH_VERSION" ]; then
    zstyle ':omz:update' mode auto
fi

ENABLE_CORRECTION="true"


ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline" 
plugins=(
	git
	zsh-syntax-highlighting	 
	zsh-autosuggestions
	web-search
    dotnet
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


export GITLAB_PAT='glpat-zbYmLmbDKLbcbR9zYmLw'
source $ZSH/oh-my-zsh.sh
source $DOTS_LOC/bash/shared_source.sh

if [ -f /opt/ros/jazzy/setup.zsh ]; then
	source /opt/ros/jazzy/setup.zsh
fi

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

