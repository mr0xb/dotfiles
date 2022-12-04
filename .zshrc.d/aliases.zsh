#===================================
# DIRECTORY MANAGEMENT
#===================================
alias ..='cd ..'
alias .1='cd ..'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='../../../../'
alias .5='cd ../../../../../'
alias APPS='cd ${HOME}/GIT_REPOS/APPLICATION-DEPLOYMENTS'
alias INFRA='cd ${HOME}/GIT_REPOS/CLOUD-INFRASTRUCTURE-TERRAFORM'
alias EKS-BASE='cd ${HOME}/GIT_REPOS/EKS-BASE-DEPLOY'
alias K8S-BASE='cd ${HOME}/GIT_REPOS/K8S-BASE-DEPLOY'
alias config='/usr/bin/git --git-dir=$HOME/.cfg/.git/ --work-tree=$HOME'

#===================================
# COMMAND MODIFICATIONS & REMAPS
#===================================
alias l='exa'
alias la='exa -aF'
#alias ls='exa -laF --color=always --icons'
alias lt='exa --tree --level=2'
alias llm='exa -lbF --git --sort=modified'
alias vi='vim'
alias dog='cat'
alias grep='grep --color=always'
alias Grep='grep'
alias Gerp='grep'
alias gerp='grep'
alias fgrep='fgrep --color=always'
alias egrep='egrep --color=always'
alias nano='vim'
alias emacs='vim'
alias notepad.exe='vim'
alias diff='colordiff --side-by-side --suppress-common-lines'
alias header='curl -I'
alias headerc='curl -I --compress'

#===================================
# AWS & INFRA-TOOLS
#===================================
#AWS
alias ac='aws-cred'
alias av='aws-vault'
alias tg='terragrunt'

#Terraform / Terragrun
alias tgp="terragrunt plan"
alias tgps="terragrunt plan --terragrunt-source-update"
alias tga="terragrunt apply"
alias tgaA="terragrunt apply -auto-approve"
alias tgas="terragrunt apply --terragrunt-source-update"
alias tgasA="terragrunt apply --terragrunt-source-update -auto-approve"
alias tgi="terragrunt init"
alias tgis="terragrunt init --terragrunt-source-update"
alias tgo="terragrunt output"

#Kuberenetes
alias kx='kubectx'
alias kn='kubens'
alias ku='kustomize'
alias kub='kustomize build --enable-alpha-plugins --load-restrictor LoadRestrictionsNone'
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kge='kubectl get events'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kgic='kubectl get ingressclass'
alias kdic='kubectl describe ingressclass'
alias kgpv='kubectl get pv'
alias kdpv='kubectl describe pv'
alias klt='kubectl logs -f'
alias kbug='kubectl run -i --tty --rm debug --image=ubuntu --restart=Never -- /bin/bash'
alias kgsec='kubectl get secret'
alias kgj='kubectl get job'
alias fqdn="kubectl get ingress -o json | jq '.items[] | .metadata.namespace + \": \" + .metadata.annotations.\"external-dns.alpha.kubernetes.io/hostname\"'"
alias fqdna="kubectl get ingress --all-namespaces -o json | jq '.items[] | .metadata.namespace + \": \" + .metadata.annotations.\"external-dns.alpha.kubernetes.io/hostname\"'"
#Kubernetes + Teleport
alias tkl='tsh kube ls'

#===================================
# USEFUL / CONVIENENCE
#===================================
alias hogs='ps -eorss,args | sort -nr | pr -TW$COLUMNS | head'
alias untar='tar -zxvf'
alias lstar='tar -tvf' 
alias perms='stat -f "%A %Sp -> owner=%SHp group=%SMp other=%SLp"'
#alias pydocs="elinks https://docs.python.org/$(python --version | awk '{print $2}' | sed 's/\.[0-9]*$//')/py-modindex.html"
if [[ "$OSTYPE" == "darwin" ]]; then
  #do mac stuff
else
  alias open='xdg-open'
  alias pydocs="w3m https://docs.python.org/$(/usr/bin/env python3 --version | awk '{print $2}' | sed 's/\.[0-9]*$//')/py-modindex.html"
fi
alias hr='printf $(printf "\e[$(shuf -i 91-97 -n 1);1m%%%ds\e[0m\n" $(tput cols)) | tr " " ='


#===================================
# DO THE SAFETY DANCE
#===================================
alias cp='cp -i'
alias rm='rm -i'
alias ln='ln -i'
alias mv='mv -i'


#===================================
# MISC 
#===================================
if [ $UID -ne 0 ]; then
  alias reboot='sudo reboot'
  if [[ $OSTYPE != 'darwin'* ]]; then
    alias upgradeall='sudo apt-get update && sudo apt-get upgrade'
  fi
fi

#===================================
# FUNCS
#===================================
#i use exa and have ls muscle memory, current version of exa does not take -t and will error out#this is a fair work around; https://github.com/ogham/exa/issues/519#issuecomment-560608534
function ls {
    if [ "$1" = "-ltr" ]; then
        exa -lsnew "${@:2}" -l -F --color=always --icons
    elif [ "$1" = "-lrt" ]; then
        exa -lsnew "${@:2}" -l -F --color=always --icons
    elif [ "$1" = "-latr" ]; then
        exa -lsnew "${@:2}" -la -F --color=always --icons
    elif [ "$1" = "-lahtr" ]; then
        exa -lsnew "${@:2}" -lah -F --color=always --icons
    elif [ "$1" = "-alhtr" ]; then
        exa -lsnew "${@:2}" -lah -F --color=always --icons
    elif [ "$1" = "latr" ]; then
        exa -lsnew "${@:3}" -lah -F --color=always --icons
    elif [ "$1" = "altr" ]; then
        exa -lsnew "${@:3}" -lah -F --color=always --icons
    elif [ "$1" = "lahtr" ]; then
        exa -lsnew "${@:3}" -lah -F --color=always --icons
    elif [ "$1" = "-altr" ]; then
        exa -lsnew "${@:2}" -lah -F --color=always --icons
    elif [ "$1" = "a-ltr" ]; then
        exa -lsnew "${@:2}" -lah -F --color=always --icons    
    else
        exa "$@" -a
    fi
}

function urlencode {
	python -c "import sys; from urllib.parse import quote_plus; print(quote_plus(sys.stdin.read()))"
}

function urldecode {
	python -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()), end='')"
}

function tfdocs {
  open "https://registry.terraform.io/search/providers?q=`echo "${@}" | urlencode`"
}

function google {
  open "https://www.google.com/search?q=`echo "${@}" | urlencode`"
}

function hred () {
        [ $# -ge 1 -a -f "$1" ] && input="$1"  || input="-"
        cat $input | grep --color -E -v '^\s*$|^\s*#.*$'
}

function run {
    "$@" < /dev/null &> /dev/null &
}

function topfile {
  find $1 -xdev -type f -ls |sort -k 7 -r -n | head -$2 |awk '{size=$7/1024/1024; printf("%dMb %s\n", size,$11);}'
}

function topdir {
  du -alx $1 | sort -n -r | head -$2 | awk '{size=$1/1024/1024; printf("%dMb %s\n", size,$2);}'
}
