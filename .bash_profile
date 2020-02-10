export GOPATH=$HOME/go_projects
export PATH=$PATH:/usr/local/go/bin
alias fp='stat --format "%a"'
gsay() { if [[ "${1}" =~ -[a-z]{2} ]]; then local lang=${1#-}; local text="${*#$1}"; else local lang=${LANG%_*}; local text="$*";fi; mplayer "http://translate.google.com/translate_tts?ie=UTF-8&tl=${lang}&q=${text}" &> /dev/null ; }
function google {
	xdg-open "https://www.google.com/search?q=`urlencode "${(j: :)@}"`"
}
# https://stackoverflow.com/questions/6250698/how-to-decode-url-encoded-string-in-shell
# Encode with URLEncode

function urlencode {
	python -c "import sys; from urllib.parse import quote_plus; print(quote_plus(sys.stdin.read()))"
}

# Decode URLencoded string
function urldecode {
	python -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()), end='')"
}
#public c ip
function myip {
  local api
  case "$1" in
      "-4")
            api="http://v4.ipv6-test.com/api/myip.php"
          ;;
      "-6")
            api="http://v6.ipv6-test.com/api/myip.php"
          ;;
      *)
            api="http://ipv6-test.com/api/myip.php"
          ;;
    esac
  curl -s "$api"
  echo # Newline.
}

alias such=git
alias very=git
alias wow='git status' 
alias hogs="ps aux | sort -nk +4 | tail -n 20"
alias perms="stat -c '%A %a %n'"
alias untar='tar -zxvf'
alias wget='wget -c'
alias randpw='openssl rand -base64 20'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias iptlist='sudo /sbin/iptables -L -n -v --line-numbers'
alias iptlistin='sudo /sbin/iptables -L INPUT -n -v --line-numbers'
alias iptlistout='sudo /sbin/iptables -L OUTPUT -n -v --line-numbers'
alias iptlistfw='sudo /sbin/iptables -l FORWARD -n -v --line-numbers'
alias firewall=iptlist
alias header='curl -I'
alias headerc='curl -I --compress'
alias rm='rm -I --perserve-root'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

if [ $UID -ne 0 ]; then
  alias reboot="sudo reboot"
  alias update="sudo apt-get update && sudo apt-get upgrade"
fi
