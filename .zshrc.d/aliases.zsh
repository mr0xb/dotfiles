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
alias l='lsd'
alias la='lsd -aF'
alias vi='nvim'
alias dog='cat'
alias grep='grep --color=auto'
alias Grep='grep'
alias Gerp='grep'
alias gerp='grep'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias nano='nvim'
alias emacs='nvim'
alias notepad.exe='nvim'
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
alias tglo="terragrunt providers lock -platform=linux_arm64 -platform=linux_amd64 -platform=darwin_amd64 -platform=darwin_arm6"
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
alias kgprca="kubectl get pods --all-namespaces --sort-by='.status.containerStatuses[0].restartCount'"
alias kgprc="kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'"
#alias kgn='kubectl get nodes'
alias kgn='kubectl get nodes --sort-by=.metadata.creationTimestamp'
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
kutil () {
        for host in $(kubectl get nodes --no-headers | cut -d' ' -f1)
        do
                echo "$host - $(kubectl get nodes -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}' $host)"
                kubectl describe node "$host" | grep --color Allocated -A 5 | grep --color -ve Event -ve Allocated -ve percent -ve --
                echo
        done
}
#===================================
# USEFUL / CONVIENENCE
#===================================
alias untar='tar -zxvf'
alias lstar='tar -tvf'
alias perms='stat -f "%A %Sp -> owner=%SHp group=%SMp other=%SLp"'
#alias pydocs="elinks https://docs.python.org/$(python --version | awk '{print $2}' | sed 's/\.[0-9]*$//')/py-modindex.html"
alias pydocs="open https://docs.python.org/$(python3 --version | awk '{print $2}' | sed 's/\.[0-9]*$//')/py-modindex.html"
alias hr='printf $(printf "\e[$(shuf -i 91-97 -n 1);1m%%%ds\e[0m\n" $(tput cols)) | tr " " ='
alias iac='cd $HOME/projects/IAC'


#===================================
# DO THE SAFETY DANCE
#===================================
alias cp='cp -i'
alias rm='rm -i'
alias ln='ln -i'
alias mv='mv -i'

#===================================
# MAC
#===================================
alias fudns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

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
#exa deprecated, replacing with lsd (github.com/lsd-rs/lsd)
#alias ls ='lsd'
#i use exa and have ls muscle memory, current version of exa does not take -t and will error out#this is a fair work around; https://github.com/ogham/exa/issues/519#issuecomment-560608534
#function ls {
#    if [ "$1" = "-ltr" ]; then
#        exa -lsnew "${@:2}" -l -F --color=auto --icons
#    elif [ "$1" = "-lrt" ]; then
#        exa -lsnew "${@:2}" -l -F --color=auto --icons
#    elif [ "$1" = "-latr" ]; then
#        exa -lsnew "${@:2}" -la -F --color=auto --icons
#    elif [ "$1" = "-lahtr" ]; then
#        exa -lsnew "${@:2}" -lah -F --color=auto --icons
#    elif [ "$1" = "-alhtr" ]; then
#        exa -lsnew "${@:2}" -lah -F --color=auto --icons
#    elif [ "$1" = "latr" ]; then
#        exa -lsnew "${@:3}" -lah -F --color=auto --icons
#    elif [ "$1" = "altr" ]; then
#        exa -lsnew "${@:3}" -lah -F --color=auto --icons
#    elif [ "$1" = "lahtr" ]; then
#        exa -lsnew "${@:3}" -lah -F --color=auto --icons
#    elif [ "$1" = "-altr" ]; then
#        exa -lsnew "${@:2}" -lah -F --color=auto --icons
#    elif [ "$1" = "a-ltr" ]; then
#        exa -lsnew "${@:2}" -lah -F --color=auto --icons
#    else
#        exa "$@" -a
#    fi
#}

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
