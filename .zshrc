eval "$(~/.local/bin/mise activate zsh)"
export AWS_VAULT_KEYCHAIN_NAME="aws-vault.keychain-db"

PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# homebrew completions must be in fpath BEFORE compinit runs
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -U compinit; compinit

alias kubectl=kubecolor

# mise completions
eval "$(mise completion zsh)"

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# fzf key bindings: ctrl+r history, alt+c cd
# ctrl+t conflicts with zellij tab mode — remapped to ctrl+f (find files)
eval "$(fzf --zsh)"
bindkey -M emacs -r '^T'
bindkey -M viins -r '^T'
bindkey -M vicmd -r '^T'
bindkey -M emacs '^F' fzf-file-widget
bindkey -M viins '^F' fzf-file-widget
bindkey -M vicmd '^F' fzf-file-widget

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters

[ -d $HOME/.zshrc.d ] && for file in $HOME/.zshrc.d/*.zsh; do source $file; done
# compdef must run after _kubectl is defined in .zshrc.d/kubectl_comp.sh
compdef kubecolor=kubectl
source ~/.local/share/fzf-tab/fzf-tab.plugin.zsh
source ~/.config/themes/fzf-challengerdeep.sh

eval "$(starship init zsh)"
