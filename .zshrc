# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="amuse"
#ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#FZF_TAB_GROUP_COLORS=(
#    $'\033[94m' $'\033[32m' $'\033[33m' $'\033[35m' $'\033[31m' $'\033[38;5;27m' $'\033[36m' \
#    $'\033[38;5;100m' $'\033[38;5;98m' $'\033[91m' $'\033[38;5;80m' $'\033[92m' \
#    $'\033[38;5;214m' $'\033[38;5;165m' $'\033[38;5;124m' $'\033[38;5;120m'
#)
#zstyle ':fzf-tab:*' group-colors $FZF_TAB_GROUP_COLORS
#zstyle ':completion:*:descriptions' format
#FZF_TAB_GROUP_COLORS=(
#    $'\033[94m' $'\033[32m' $'\033[33m' $'\033[35m' $'\033[31m' $'\033[38;5;27m' $'\033[36m' \
#    $'\033[38;5;100m' $'\033[38;5;98m' $'\033[91m' $'\033[38;5;80m' $'\033[92m' \
#    $'\033[38;5;214m' $'\033[38;5;165m' $'\033[38;5;124m' $'\033[38;5;120m'
#)
#zstyle ':fzf-tab:*' group-colors $FZF_TAB_GROUP_COLORS
#zstyle ':completion:*:descriptions' format
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
plugins=(git fzf zsh-autosuggestions fzf-tab zsh-syntax-highlighting kubectl)

source $ZSH/oh-my-zsh.sh


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

eval "$(/Users/steve.briggs/.local/bin/mise activate)"
# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export PATH="${PATH}:/Users/steve.briggs/.cargo/bin"
export PATH="/usr/local/opt/openssl/bin:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/curl/bin:${PATH}"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
#export PATH="/usr/local/opt/curl/bin:/usr/local/opt/coreutils/libexec/gnubin"
export PATH="${HOME}/.pyenv/bin:${HOME}/.config/cloud-ops/scripts:${PATH}"
#export PATH="${HOME}/.config/cloud-ops/scripts:${PATH}"
export PATH="${HOME}/.local/bin:${HOME}/.local/bin/custom:${PATH}"
#export PATH="/Users/steve.briggs/go/bin:$PATH"
export PATH="/usr/local/bin:${PATH}"
export PATH="${PATH}:${HOME}/.krew/bin"
#export PATH="/Users/steve.briggs/.local/share/mise/installs/yq/4.34.1/bin:/Users/steve.briggs/.local/share/mise/installs/jq/1.6/bin:/Users/steve.briggs/.local/share/mise/installs/direnv/2.32.2/bin:/Users/steve.briggs/.local/share/mise/installs/helm/3.10.2/bin:/Users/steve.briggs/.local/share/mise/installs/exa/0.10.1/bin:/Users/steve.briggs/.local/share/mise/installs/go/1.22.2/go/bin:/Users/steve.briggs/.local/share/mise/installs/go/1.22.2/packages/bin:/Users/steve.briggs/.local/share/mise/installs/kustomize/4.5.0/bin:/Users/steve.briggs/.local/share/mise/installs/sops/3.6.1/bin:/Users/steve.briggs/.local/share/mise/installs/terraform/1.3.7/bin:/Users/steve.briggs/.local/share/mise/installs/vault/1.12.1/bin:/Users/steve.briggs/.local/share/mise/installs/kubectl/1.25.8/bin:/Users/steve.briggs/.local/share/mise/installs/poetry/1.7.1/bin:/Users/steve.briggs/.local/share/mise/installs/kubecolor/0.0.25/bin:/usr/local/opt/libpq/bin:/Users/steve.briggs/.local/bin:/bin:/Users/steve.briggs/.cargo/bin:/Users/steve.briggs/.config/cloud-ops/scripts:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:/Users/steve.briggs/.local/bin:/Users/steve.briggs/.pyenv/bin:/Users/steve.briggs/.cargo/bin:/Users/steve.briggs/.config/cloud-ops/scripts:/Users/steve.briggs/.pyenv/bin:/Users/steve.briggs/.local/bin:/Users/steve.briggs/.pyenv/bin:/Users/steve.briggs/.cargo/bin:/Users/steve.briggs/.config/cloud-ops/scripts:/Users/steve.briggs/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/steve.briggs/.bin:/bin:/Users/steve.briggs/go/bin:/private/var/folders/ky/m6p32md91_n2q6z94fdn8fsw0000gq/T/AppTranslocation/F252CD76-5A71-4D7F-8826-12175DB43E32/d/Visual Studio Code.app/Contents/Resources/app/bin:/Users/steve.briggs/.bin:/bin:/Users/steve.briggs/go/bin/:/private/var/folders/ky/m6p32md91_n2q6z94fdn8fsw0000gq/T/AppTranslocation/F252CD76-5A71-4D7F-8826-12175DB43E32/d/Visual Studio Code.app/Contents/Resources/app/bin:/usr/local/opt/openssl/bin:/usr/local/bin:/Users/steve.briggs/.bin:/bin:/Users/steve.briggs/go/bin/:/private/var/folders/ky/m6p32md91_n2q6z94fdn8fsw0000gq/T/AppTranslocation/F252CD76-5A71-4D7F-8826-12175DB43E32/d/Visual Studio Code.app/Contents/Resources/app/bin:/usr/local/opt/fzf/bin"
export PATH="/opt/homebrew/bin:${PATH}"
alias kubectl=kubecolor
autoload -U compinit; compinit
compdef kubecolor=kubectl


#[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
#source <(kubectl completion zsh)
[ -d $HOME/.zshrc.d ] && for file in $HOME/.zshrc.d/*.zsh; do source $file; done
#autoload -Uz compinit
#compinit
#eval "$(fzf --zsh)"
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --icon always -1 --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
alias ls='lsd -lahtr'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
#export PATH="$PATH:/usr/local/opt/curl/bin:/usr/local/opt/coreutils/libexec/gnubin"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters
#Star Ship
eval "$(starship init zsh)"
PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
export GPG_TTY=$(tty)


# Load Angular CLI autocompletion.
source <(ng completion script)
alias config='/usr/bin/git --git-dir=/Users/steve.briggs/.cfg/ --work-tree=/Users/steve.briggs'
