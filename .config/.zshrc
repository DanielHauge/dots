export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="bira"
zstyle ':omz:update' mode auto      

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

source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

